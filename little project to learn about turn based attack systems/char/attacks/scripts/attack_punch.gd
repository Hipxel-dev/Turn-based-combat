extends Spatial
class_name attack 

var who_to_attack = null
export var dmg = 40

func _ready() -> void:
	if who_to_attack != null:
		who_to_attack.damage(dmg)
