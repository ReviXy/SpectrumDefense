extends EnemyAttachment

@export var Shields: Array[Shield]

func _ready() -> void:
	pass
## This is needed because the references get duplicated on instantiation.
## This way the array copies itself into the instance, leaving it with a clone
	#for i in range(Shields.size()):
		#Shields[i] = Shields[i].duplicate()

func pre_damage(_baseDamage:float, _preSum:Ref, _mult:Ref, _sum:Ref, _color:Color):
	var i = -1
	for a in range(Shields.size()):
		if (not (Parent.Attachments.has("Suppressed")) or (not (Parent.Attachments["Suppressed"] as Suppressed).Colors.has(Shields[a].WeakColor))):
			i = a
			break
	if i == -1:
		#All shields are suppressed or there are no shieds yet, let the damage pass.
		return true
	Shields[i].HP -= max(_baseDamage*(2.0 if _color == Shields[i].WeakColor else (0.25 if _color == Shields[i].StrongColor else 1.0)),0.0)
	if (Shields[i].HP <= 0):
		Shields.remove_at(i)
		if Shields.size() == 0:
			_exit_tree()
	return false

func  add_shield(hp: float, weakColor: Color):
	Shields.push_back(Shield.new(hp, weakColor))

#A single shield is HP and a dictionary of Colors.
