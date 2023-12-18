extends KinematicBody
class_name fighter

export var name1 = ""

export var hp = 100
export var sp = 100

var max_hp = hp
var max_sp = sp

var turn_available = false

var dmg_number = preload("res://scene/effects/dmg_number.tscn")

enum state {
	ALIVE,
	DEAD
}
var current_state = state.ALIVE
onready var attacks = []

func _ready() -> void:
	max_hp = hp
	max_sp = sp
	attacks

func attack(what, dmg):
	what.damage(dmg)

func damage(dmg):
	hp -= dmg
	var dmg_number_inst = dmg_number.instance()
	dmg_number_inst.translation = translation
	dmg_number_inst.text = str(dmg)
	get_parent().add_child(dmg_number_inst)
	
func _physics_process(delta: float) -> void:
	if hp < 0:
		current_state = state.DEAD
	else:
		current_state = state.ALIVE
		
	if current_state == state.DEAD:
		hide()
	else:
		show()
		
		
		
		
		
		
		
		
