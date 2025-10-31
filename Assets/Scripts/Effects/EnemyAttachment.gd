extends Node
##This class is used for various effects that can affect an entity.
##This is a class so it can have it's own animations and effects (Like the shield).
##This should be attached to the entity's base Node.
class_name EnemyAttachment

var Parent: BaseEntity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Parent = get_parent() as BaseEntity
	Parent.Attachments[name] = self

func _exit_tree() -> void:
	Parent.Attachments.erase(name)

func pre_physics_process():
	pass

##damage is calculated with this formula: y = (x+preSum)*mult+sum
##if any function returns false, the damage is fully negated and post_damage isn't called
##baseDamage is the raw damage that would be dealt.
##preSum, mult and sum can be changed
##baseDamage can't and only serves to show how much damage would have been taken (shields)
func pre_damage(_baseDamage: float, _preSum:Ref, _mult:Ref, _sum:Ref, _color:Color):
	return true

func post_damage(_damage: float, _color: Color):
	pass
