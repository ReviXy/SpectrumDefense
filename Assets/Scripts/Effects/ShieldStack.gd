extends EnemyAttachment
class_name ShieldStack

@export var Shields: Array[Shield]
@export var ShieldMesh: MeshInstance3D

const BaseInstance = preload("res://Assets/Scenes/Statuses/ShieldStack.tscn")

signal OnDestroyAny

signal OnDestroyAll

func _ready() -> void:
	super()
	if Parent:
		var area = Parent.find_child("Area3D")
		if area:
			var coll: CollisionShape3D = area.find_child("CollisionShape3D")
			if coll:
				var aabb = coll.shape.get_debug_mesh().get_aabb()
				var center = coll.global_transform * aabb.get_center()
				var extend = aabb.size * 0.5 * coll.global_transform.basis.get_scale()
				var radius = sqrt(pow(extend.x,2)+pow(extend.y,2)+pow(extend.z,2))
				global_transform.origin = center
				scale = Vector3(1,1,1)*radius
			
## This is needed because the references get duplicated on instantiation.
## This way the array copies itself into the instance, leaving it with a clone
	for i in range(Shields.size()):
		Shields[i] = Shields[i].duplicate(true)
	update_graphic()

func pre_damage(_baseDamage:float, _color:ColorRYB_Operations.ColorRYB, _preSum:Ref, _mult:Ref, _sum:Ref):
	var i = -1
	for a in range(Shields.size()-1,-1,-1):
		if (not Parent) or (not (Parent.Attachments.has("Suppressed")) or (not (Parent.Attachments["Suppressed"] as Suppressed).Colors.has(Shields[a].WeakColor))):
			i = a
			break
	if i == -1:
		update_graphic()
		#All shields are suppressed or there are no shieds yet, let the damage pass.
		return true
	Shields[i].currentHP -= max(_baseDamage*(2.0 if _color == Shields[i].WeakColor else (0.25 if _color == Shields[i].StrongColor else 1.0)),0.0)
	if (Shields[i].currentHP <= 0):
		Shields[i].OnDestroy.emit()
		OnDestroyAny.emit()
		Shields.remove_at(i)
		if Shields.size() == 0:
			OnDestroyAll.emit()
			queue_free()
	update_graphic()
	return false

func  _process(_delta: float) -> void:
	#pre_damage(1,Color(1,0,1),null,null,null)
	pass

func  add_shield(hp: float, weakColor: ColorRYB_Operations.ColorRYB):
	var S = Shield.new()
	S.HP = hp
	S.currentHP = hp
	S.WeakColor = weakColor
	Shields.push_back(S)
	update_graphic()

func update_graphic():
	var shader_material : ShaderMaterial = ShieldMesh.material_override
	var i = -1
	for a in range(Shields.size()-1,-1,-1):
		if (not Parent) or (not (Parent.Attachments.has("Suppressed")) or (not (Parent.Attachments["Suppressed"] as Suppressed).Colors.has(Shields[a].WeakColor))):
			i = a
			break
	if i == -1:
		shader_material.set_shader_parameter("fresnel_color",Color(1,1,1))
		shader_material.set_shader_parameter("_panning",0.1)
		shader_material.set_shader_parameter("_displacement",0.1)
	else:
		var instability = (1-Shields[i].currentHP/Shields[i].HP)*0.25+0.05
		shader_material.set_shader_parameter("fresnel_color",ColorRYB_Operations.ToColor(Shields[i].WeakColor))
		shader_material.set_shader_parameter("_panning",instability)
		shader_material.set_shader_parameter("_displacement",instability)
	
#A single shield is HP and a dictionary of Colors.
