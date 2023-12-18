extends Spatial

onready var cam_pivot = $cam_pivot
onready var camera = $cam_pivot/camera

onready var chars = [$Kris, $Ralsei, $Susie]
var char_index = 0
onready var selected_char = $Kris

var enemy_index = 0
var selected_enemy = null
var just_selected_enemy_select_state = false
var enemy_scenes = [
	preload("res://enemy/enemy_lunger.tscn"),
	preload("res://enemy/enemy_lunger.tscn"),
	preload("res://enemy/enemy_lunger.tscn")
	]
var enemies = []

var attack_index = 0
onready var attack_select_inst = $ui/attack_select/attack_selection
var just_selected_attack_select_state = false
var selected_char_attack = null
var char_attack_selection = []
var current_char_attacks = []
var just_attacked = false

onready var camera_focus = $Kris

enum states {
	INTRO,
	PLAYER_CONTROL,
	PLAYER_SELECT_ATTACK,
	PLAYER_SELECT_ENEMY,
	CHARACTER_ATTACK,
	ENEMY_TURN,
	ENEMY_ATTACK,
	ALL_OUT_ATTACK,
	WIN,
	OUTRO
}

var shake = 0

var change_to_player_control_delay = 0.5
var current_state = states.PLAYER_CONTROL


func _ready() -> void:
	
	for i in range(enemy_scenes.size()):
		var enemy_inst = enemy_scenes[i].instance()
		enemy_inst.translation = $enemy_initial_pos.translation
		enemy_inst.translation += Vector3(cos(i), 0 ,sin(i)) * 2
		add_child(enemy_inst)
		enemies.append(enemy_inst)
		
	selected_enemy = enemies[0]
		

func char_selection(delta):
	
	if Input.is_action_just_pressed("RIGHT"):
		if char_index > 0:
			char_index -= 1
		else:
			char_index = chars.size() - 1
	if Input.is_action_just_pressed("LEFT"):
		if char_index < chars.size() - 1:
			char_index += 1
		else:
			char_index = 0
			
	selected_char = chars[char_index]
	camera_focus = selected_char
	$ui/select_fx.position = $ui/select_fx.position.linear_interpolate(
		camera.unproject_position(selected_char.translation), delta * 15
	)
	if Input.is_action_just_pressed("ui_accept"):
		selected_char = chars[char_index]
		current_state = states.PLAYER_SELECT_ATTACK
		
func camera_system(delta):
	var target_rotation = camera.global_transform.looking_at((camera_focus.global_transform.origin + Vector3(0,7,0)) * 0.2, Vector3.UP)
	camera.global_transform = camera.global_transform.interpolate_with(target_rotation, 0.1)
	

func ui_char_info(delta):
		
	$ui/char_info.modulate = $ui/char_info.modulate.linear_interpolate(Color.white, delta * 15)
	$ui/char_info.position /= 2
	
	$ui/char_info/name_text.text = str(selected_char.name)
	
	$ui/char_info/hp.value = selected_char.hp
	$ui/char_info/hp.max_value = selected_char.max_hp
	
	$ui/char_info/sp.value = selected_char.sp
	$ui/char_info/sp.max_value = selected_char.max_sp
	
	$ui/char_info/hptext.text = str(selected_char.hp, " /", selected_char.max_hp)
	$ui/char_info/sptext.text = str(selected_char.sp, " /", selected_char.max_sp)
	
	$ui/select_fx/hpbar.value = selected_char.hp
	$ui/select_fx/hpbar.max_value = selected_char.max_hp

func ui_manager(delta):
	if not current_state == states.PLAYER_SELECT_ATTACK:
		$ui/attack_select.modulate = $ui/attack_select.modulate.linear_interpolate(Color.transparent, delta * 5)
	if not current_state == states.PLAYER_SELECT_ENEMY:
		$ui/enemy_info.modulate = $ui/enemy_info.modulate.linear_interpolate(Color.transparent, delta * 5)

func _physics_process(delta: float) -> void:
	ui_manager(delta)
	if Input.is_action_pressed("ui_cancel"):
		$cam_pivot/camera.rotation_degrees = Vector3(5,5,0)
	
	if current_state == states.PLAYER_CONTROL:
		char_selection(delta)
		ui_char_info(delta)
		
	if current_state == states.PLAYER_SELECT_ATTACK:
		attack_selection(delta)
	else:
		just_selected_attack_select_state = false
		
	if current_state == states.PLAYER_SELECT_ENEMY:
		enemy_selection(delta)
	else:
		just_selected_enemy_select_state = false
	
	if current_state == states.WIN:
		win_state(delta)
	
	if enemies.size() == 0:
		current_state = states.WIN
		
	enemies = []
	
	for i in get_tree().get_nodes_in_group("enemy"):
		if i.current_state == i.state.ALIVE:
			enemies.append(i)
	
	camera_system(delta)
	
func attack_selection(delta):
	$ui/select_fx.position = $ui/select_fx.position.linear_interpolate(
		camera.unproject_position(selected_char.translation), delta * 15
	)
	$cam_pivot/camera.rotation_degrees += Vector3(0.3,0,0)
	$ui/attack_select.modulate = $ui/attack_select.modulate.linear_interpolate(Color.white, delta * 8)
	if Input.is_action_just_pressed("ui_accept") and just_selected_attack_select_state == true:
		current_state = states.PLAYER_SELECT_ENEMY
		
	if just_selected_attack_select_state == false:
	
		just_selected_attack_select_state = true
		
#	selected_char_attack = current_char_attacks[attack_index]

func enemy_selection(delta):
		
	$ui/enemy_info.modulate = $ui/enemy_info.modulate.linear_interpolate(Color.white, delta * 7)
	if enemy_index < enemies.size():
		selected_enemy = enemies[enemy_index]
		if not just_attacked:
			camera_focus = selected_enemy
	else:
		enemy_index -= 1
	
	if Input.is_action_just_pressed("RIGHT"):
		if enemy_index > 0:
			enemy_index -= 1
		else:
			enemy_index = enemies.size() - 1
			
	if Input.is_action_just_pressed("LEFT"):
		if enemy_index < enemies.size() - 1:
			enemy_index += 1
		else:
			enemy_index = 0
	
	# attack
	if Input.is_action_just_pressed("ui_accept") and just_selected_enemy_select_state and not just_attacked:
		just_attacked = true
		selected_char.attack(selected_enemy, 40)
		$ui/select_fx.position.y += -4
		$ui/enemy_info/enemy_name.text = str(selected_enemy.name1)
		
		$ui/select_fx/hpbar.value = selected_enemy.hp
		$ui/select_fx/hpbar.max_value = selected_enemy.max_hp
		if char_index < chars.size() - 1:
			char_index += 1
		else:
#			current_state = states.ENEMY_TURN
			char_index = 0
		
		
	if just_attacked:
		change_to_player_control_delay -= delta
		if change_to_player_control_delay < 0:
			current_state = states.PLAYER_CONTROL
			change_to_player_control_delay = 0.5
			just_attacked = false
		
	if just_selected_enemy_select_state == false:
		$cam_pivot/camera.rotation_degrees += Vector3(0,1,0)
		just_selected_enemy_select_state = true
	
	if not just_attacked:
		$ui/select_fx.position = $ui/select_fx.position.linear_interpolate(
			camera.unproject_position(selected_enemy.translation), delta * 15
		)
		
		$ui/enemy_info/enemy_name.text = str(selected_enemy.name1)
		
		$ui/select_fx/hpbar.value = selected_enemy.hp
		$ui/select_fx/hpbar.max_value = selected_enemy.max_hp
		
func win_state(delta):
	$ui/win_screen.modulate = $ui/win_screen.modulate.linear_interpolate(Color.white, delta * 15)
	$ui/win_screen.position /= 1.1
	
	$ui/select_fx.hide()
	$ui/char_info.hide()
	$ui/enemy_info.hide()
	
	
	
	
