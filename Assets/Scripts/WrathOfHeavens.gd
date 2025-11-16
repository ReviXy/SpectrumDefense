extends Node3D

@onready var camera := get_viewport().get_camera_3d()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT and camera:
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * 1000
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to, 2)
		query.collide_with_areas = true
		var result = space_state.intersect_ray(query)
		if result.has("collider"):
			var Enemy = (result["collider"] as Node3D).get_parent_node_3d() as BaseEntity
			Enemy.TakeDamage(20,Color(0,0,0))
