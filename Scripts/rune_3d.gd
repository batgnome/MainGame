extends CharacterBody3D


var tilesize = 1
var inputs = {"right": Vector3i.RIGHT, "left": Vector3i.LEFT, "up": Vector3i.FORWARD, "down": Vector3i.BACK}
var markers = []  # Array to store move option markers
enum States { MOVE, ATTACK, END, WAIT }
enum SelectState {SELECTED, NOTSELECTED}
var current_state = States.MOVE
var follower_frame = 1
var path = []
var follower_scene = preload("res:///Scenes/tail_3d.tscn")
var followers = []
var group = ""
var players_in_range = []
var enems_in_range = []
var danger = false
@export var attributes = {
	"name": "player",
	"health": 3,
	"maxSize": 3,
	"defense": 2,
	"maxMove": 10,
	"attackRange": 3,
	"attackPower": 2,
	"speed": 1,
	"sprite":"res://player.png",
	"group":"player"
}
var pressed = false
var target: CharacterBody2D
var currentSize = 0
var currentMove = attributes.maxMove
var parent = null
var selected = false
var inMouse = false

func get_group():
	return attributes.group
	
func set_attributes():
	add_to_group("Player")
	attributes = attributes

func _ready():
	
	init()
	
func init():
	# Set the parent node
	parent = get_parent()
	if parent == null:
		print("Error: Parent is null!")
		return

	# Set attributes
	set_attributes()

 	# Ensure the path array has an initial position
	# if path.size() == 0:  # Check if the array is empty
	# 	path.append(global_transform.origin)  # Add the current position
	# 	print("Initial position added to path: ", global_transform.origin)
	# else:
	# 	print("Path already initialized with: ", path)
		
	# Add the first position for the tail segments so that the first segment isn't under the head
	path.insert(0, global_transform.origin)	



func _process(delta):
	
	#this is the timer for the node
	$TurnTimer.set_value(($turn.get_time_left()/$turn.wait_time)*100)
	if selected:
		update_move_options()
	
	#this starts the timer 
	if current_state == States.ATTACK && $turn.time_left  <=0:
		$turn.start(attributes.speed)

func _unhandled_input(event):
	#can move rune if this is the selected
	#if selected:
		# material = $Sprite2D.material 
		# if material is ShaderMaterial:
		# 	material.set_shader_parameter("width", 4.0) 
	if event.is_action_pressed("reset"):
		current_state = States.ATTACK
	if event.is_action_pressed("del"):
		delete(1)
	else:
		movement(event)
	#this selects this rune
	#elif event.is_action_pressed("move") and inMouse:
		#selected = true
		#parent.selected.selected = false
		#for marker in parent.selected.markers:
			#if is_instance_valid(marker):
				#marker.queue_free()
				#markers.clear()
		#parent.selected = self
	# else:
	# 	material = $Sprite2D.material 
	# 	if material is ShaderMaterial:
	# 		material.set_shader_parameter("width", 0.0) 

func movement(event):
	if currentMove > 0:
		for dir in inputs.keys():
			if event.is_action_pressed(dir):
				var current_pos = position
				print(position)
				var direction = Vector3(inputs[dir].x, 0, inputs[dir].z) * tilesize
				var collision = move_and_collide(direction)
				if !is_instance_valid(collision):
					currentMove -= 1
					path.insert(0, position)
					if path.size() > attributes.maxSize + 1:
						path.pop_back()
					if followers.size() < attributes.maxSize:
						add_follower()
					update_followers()
					update_move_options()
				else:
					var transform_copy = global_transform
					transform_copy.origin = current_pos
					global_transform = transform_copy
	else:
		current_state = States.ATTACK



func update_move_options():
	var moves = 0
	var marker_mesh = preload("res://scenes/marker_3d.tscn")  # Replace with your 3D marker mesh
	if current_state == States.MOVE:
		moves = currentMove
	elif current_state == States.ATTACK:
		moves = attributes.attackRange

	for marker in markers:
		if is_instance_valid(marker):
			marker.queue_free()
	markers.clear()

	#for x in range(-moves, moves + 1):
		#for y in range(-moves, moves + 1):
			#for z in range(-moves, moves + 1):
				#if abs(x) + abs(y) + abs(z) <= moves and (x != 0 or y != 0 or z != 0):
					#var marker = marker_mesh.instantiate()
					#marker.global_transform.origin = global_transform.origin + Vector3(x * tilesize, y * tilesize, 1)
					#add_child(marker)
					#markers.append(marker)
	for x in range(-moves, moves + 1):
		for z in range(-moves, moves + 1):
			if abs(z) + abs(x) <= moves:
				if  abs(z) + abs(x) !=0:
					var marker = marker_mesh.instantiate()
					marker.position = global_transform.origin -position + Vector3(x * tilesize,0, z * tilesize)
					add_child(marker)
					markers.append(marker)


							
func add_follower():
	var new_follower = follower_scene.instantiate()
	var follower_mesh = new_follower.get_node("Mesh")
	var rune_mesh = get_node("Mesh")
	follower_mesh.material_override = rune_mesh.material_override
	follower_mesh.set_surface_override_material(0, rune_mesh.get_surface_override_material(0))
	# new_follower.change_sprite('res://Textures/'+attributes.name+'_tail.png')
	print(get_node("Mesh"))
	new_follower.setText(followers.size())
	new_follower.add_to_group(attributes.group)
	add_child(new_follower)
	followers.append(new_follower)
	updateParent(new_follower)
	# Update the position immediately to prevent initial overlap
	if path.size() >= followers.size():
		new_follower.position = path[followers.size() - 1]

func update_followers():
	for i in range(followers.size()):
		if path.size() > i + 1 and is_instance_valid(followers[i]):
			var transform_copy = followers[i].global_transform
			transform_copy.origin = path[i + 1]
			followers[i].global_transform = transform_copy
			followers[i].setText(i)


func _on_turn_timeout():
	$turn.stop()
	currentMove = attributes.maxMove
	current_state = States.MOVE

func get_nearest_player():
	var nearest_player = null
	var nearest_dist = 1e10
	for player in get_parent().PlayRunes:
		if is_instance_valid(player):
			var dist = global_position.distance_to(player.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest_player = player
	return nearest_player
	
func _on_hitbox_input_event(viewport, event, shape_idx):
	if event.is_action_pressed('move'):
		pressed = true
	else:
		pressed = false
		
func delete(segs):
	
	var l = 0
	var s = 0
	var temp = null
	if segs >= followers.size():
		l = followers.size()
		s = followers.size()
	else:
		l = segs
		s = segs
	var index = followers.size() - 1
	while l > 0:
		
		parent.EnemRunes.erase(followers[index])
		parent.PlayRunes.erase(followers[index])
		temp = followers[index]
		followers.erase(followers[index])
		await temp.play_deletion_animation()
		#f.queue_free()
		update_followers()
		l -= 1
		index -= 1
		#await get_tree().create_timer(0.2).timeout  # Adjust delay time (in seconds) as needed
	
	if s != segs:
		parent.EnemRunes.erase(self)
		parent.PlayRunes.erase(self)
		queue_free()


func updateParent(tail):
	
	if get_group() == 'Player':
		parent.PlayRunes.append(tail)
	elif get_group() =='enemy':
		parent.EnemRunes.append(tail)
	


func _on_area_2d_mouse_entered():
	inMouse = true
	# material = $Sprite2D.material 
	# if material is ShaderMaterial:
	# 	material.set_shader_parameter("width", 4.0) 


func _on_area_2d_mouse_exited():
	inMouse = false
	# material = $Sprite2D.material  
	# if material is ShaderMaterial:
	# 	material.set_shader_parameter("width", 0.0)  # Disable outline
