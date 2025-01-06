extends Node2D

@onready var tile_map = %TileMap
var tile_pos = Vector2()
var selected =null
var enemSelected =null
var PlayRunes = []
var EnemRunes = []
var EnemRunesSelect = []
enum States { PREP, GAME, PAUSE }
# Called when the node enters the scene tree for the first time.
func _ready():
	
	for e in get_children():
		if e.is_in_group('Player'):
			PlayRunes.append(e)
		elif  e.is_in_group('enemy'):
			EnemRunes.append(e)
			EnemRunesSelect.append(e)
			
	selected = PlayRunes[0]
	selected.selected = true
	
	enemSelected = EnemRunesSelect[0]
	enemSelected.enemSelected = true
	
	tile_pos = tile_map.local_to_map(get_local_mouse_position())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	playerLogic()
	enemyLogic()
	
func playerLogic():
	if !is_instance_valid(selected):
		for e in get_children():
			if e.is_in_group('Player'):
				PlayRunes.append(e)
			elif  e.is_in_group('enemy'):
				EnemRunes.append(e)
		selected = null
		for s in PlayRunes:
			if is_instance_valid(s):
				print("got em")
				selected = s
				selected.selected = true
				break;
		if selected == null:
			print("game over")
			
	#print(EnemRunes)
	if is_instance_valid(selected):
		if selected.current_state == 1:
			for e in EnemRunes:
				if is_instance_valid(e):
					if((selected.position - e.position).length()/64 <= selected.attributes.attackRange):
						if(e.pressed):
							print(e)
							e.delete(selected.attributes.attackPower)
							e.pressed = false
							selected.current_state = 0
					
var current_enemy_index = 0  # Tracks the index of the selected enemy

func enemyLogic():
	# Check if current enemy is invalid or deselected
	if !is_instance_valid(enemSelected) or !enemSelected.enemSelected:
		# Select the next enemy in the list
		select_next_enemy()
	else:
		# Let the current enemy process its turn
		enemSelected.enemSelected = true

func select_next_enemy():
	#rawait get_tree().create_timer(0.5).timeout
	if current_enemy_index >= EnemRunesSelect.size():
		current_enemy_index = 0	
	print(current_enemy_index)
	if is_instance_valid(EnemRunesSelect[current_enemy_index]):
		EnemRunesSelect[current_enemy_index].enemSelected = false
		var enemy = EnemRunesSelect[current_enemy_index]
	
		enemSelected = enemy
		enemSelected.enemSelected = true
		current_enemy_index += 1
		return
	else:
		# Skip invalid enemies
		current_enemy_index += 1

	# Reset index if all enemies are processed

