extends Node3D
##This class is used for various effects that can affect an entity.
##This is a class so it can have it's own animations and effects (Like the shield).
##This should be attached to the entity's base Node.
class_name EnemyAttachment
const ColorRYB = ColorRYB_Operations.ColorRYB

var Parent: BaseEntity

func _ready() -> void:
	Parent = get_parent() as BaseEntity
	if Parent:
		Parent.Attachments[name] = self
		

func _exit_tree() -> void:
	if Parent:
		Parent.Attachments.erase(name)

func pre_physics(_delta: float):
	pass

func post_physics(_delta: float, _distance: float):
	pass

##damage is calculated with this formula: y = (x+preSum)*mult+sum
##if any function returns false, the damage is fully negated and post_damage isn't called
##baseDamage is the raw damage that would be dealt.
##preSum, mult and sum can be changed
##baseDamage can't and only serves to show how much damage would have been taken (shields)
func pre_damage(_baseDamage: float, _color:ColorRYB, _preSum:Ref, _mult:Ref, _sum:Ref):
	return true

func post_damage(_damage: float, _color: ColorRYB):
	pass

func pre_death():
	pass

func on_death():
	pass

func on_end_reached():
	pass
