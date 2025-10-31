@abstract
class_name Target extends MeshInstance3D

var can_stop_laser: bool

@abstract
func Got_hit_by_laser(laser: Node) -> void
	
@abstract
func While_hit_by_laser(laser: Node) -> void
