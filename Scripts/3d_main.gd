extends Node3D


# @onready var tile_map = %TileMap
var tile_pos = Vector2()
var selected =null
var enemSelected =null
var PlayRunes = []
var EnemRunes = []
var EnemRunesSelect = []
enum States { PREP, GAME, PAUSE }
# @onready var basic_ui = $CanvasLayer
# Called when the node enters the scene tree for the first time.
func _ready():
	#basic_ui.visible = false
	# basic_ui.get_child(0).visible = false
	# basic_ui.get_child(1).visible = false
	# center_ui()
	#  # Connect the Restart button
	# basic_ui.get_node("GameOverMenu/GameOverBox/HBoxContainer/Restart").connect("pressed", Callable(self, "_on_restart_pressed"))

	# # Connect the Quit button
	# basic_ui.get_node("GameOverMenu/GameOverBox/HBoxContainer/Quit").connect("pressed", Callable(self, "_on_quit_pressed"))
	
	# basic_ui.get_node("PauseMenu/GameOverBox/HBoxContainer/Restart").connect("pressed", Callable(self, "_on_restart_pressed_pause"))
	# basic_ui.get_node("PauseMenu/GameOverBox/HBoxContainer/Continue").connect("pressed", Callable(self, "_on_continue_pressed_pause"))

	# # Connect the Quit button
	# basic_ui.get_node("PauseMenu/GameOverBox/HBoxContainer/Quit").connect("pressed", Callable(self, "_on_quit_pressed_pause"))
	
	get_tree().paused = false
	for e in get_children():
		if e.is_in_group('Player'):
			PlayRunes.append(e)
		elif  e.is_in_group('enemy'):
			EnemRunes.append(e)
			EnemRunesSelect.append(e)
			
	selected = PlayRunes[0]
	selected.selected = true
	
	if EnemRunesSelect.size() >0:
		enemSelected = EnemRunesSelect[0]
		enemSelected.enemSelected = true
	
	# tile_pos = tile_map.local_to_map(get_local_mouse_position())


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func center_ui():
# 	# Access the GameOverBox node
# 	var game_over_box = basic_ui.get_node("GameOverMenu/GameOverBox")
# 	var paused_box = basic_ui.get_node("PauseMenu/GameOverBox")
	
# 	if game_over_box is Sprite2D: 
# 		game_over_box.position = Vector2(
# 			(get_viewport().size.x) / 2,
# 			(get_viewport().size.y) / 2
# 		)
# 	else:
# 		print("Error: GameOverBox is not a Sprite2D!")
# 	if paused_box is Sprite2D: 
# 		paused_box.position = Vector2(
# 			(get_viewport().size.x) / 2,
# 			(get_viewport().size.y) / 2
# 		)
# 	else:
# 		print("Error: GameOverBox is not a Sprite2D!")
func _process(delta):
	# print(delta)	
	playerLogic()
	#enemyLogic()
	
func _unhandled_input(event):
	
	if event.is_action_pressed("pause"):
		# basic_ui.get_child(1).visible = true
		get_tree().paused = true



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
			show_game_over()
			
	#print(EnemRunes)
	#if is_instance_valid(selected):
		#if selected.current_state == 1:
			#for e in EnemRunes:
				#if is_instance_valid(e):
					#if((selected.position - e.position).length()/64 <= selected.attributes.attackRange):
						#if(e.pressed):
							#print(e)
							#e.delete(selected.attributes.attackPower)
							#e.pressed = false
							#selected.current_state = 0
					
var current_enemy_index = 0  # Tracks the index of the selected enemy

# Show the game over screen
func show_game_over():
	# basic_ui.get_child(0).visible = true
	get_tree().paused = true
	



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



func _on_restart_button_down():
	print("restart")
	if is_inside_tree():
		print(get_tree())
		get_tree().paused = false
		get_tree().reload_current_scene()


func _on_quit_button_down():
	if is_inside_tree():
		print("quit")
		get_tree().quit()


func _on_quit_button_down_pause():
	print("restart")
	if is_inside_tree():
		print(get_tree())
		get_tree().paused = false
		get_tree().reload_current_scene()



func _on_continue_button_down_pause():
	# basic_ui.get_child(1).visible = false
	get_tree().paused = false

func _on_restart_button_down_pause():
	if is_inside_tree():
		print("quit")
		get_tree().quit()
