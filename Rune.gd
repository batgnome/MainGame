extends CharacterBody2D
var tilesize =32
var inputs = {"right": Vector2.RIGHT, "left": Vector2.LEFT, "up": Vector2.UP, "down": Vector2.DOWN}
var markers = []  # Array to store move option markers
enum States { MOVE, ATTACK, END, WAIT }
enum SelectState {SELECTED, NOTSELECTED}
var current_state = States.MOVE
var follower_frame = 1
var path = []
var follower_scene = preload("res:///tail.tscn")
var followers = []
var group = ""
var players_in_range = []
var enems_in_range = []
var danger = false
var attributes = {
	"name": "player",
	"health": 3,
	"maxSize": 3,
	"defense": 2,
	"maxMove": 3,
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
	parent = get_parent()
	set_attributes()
	$Sprite2D.texture = load(attributes.sprite)
	$Sprite2D.material.set("shader_param/outline_thickness", 0.0)
	currentMove = attributes.maxMove
	#add the first position for the tail segments so that the first segment isn't under the head
	path.insert(0, position)

func _process(delta):
	
	#this is the timer for the node
	$TurnTimer.set_value(($turn.get_time_left()/$turn.wait_time)*100)
	if selected:
		update_move_options()
	
	#this starts the timer 
	if current_state == States.ATTACK && $turn.time_left  <=0:
		$turn.start(attributes.speed)

func _unhandled_input(event):
	if selected:
		if event.is_action_pressed("reset"):
			current_state = States.ATTACK
		if event.is_action_pressed("del"):
			delete(1)
		if current_state == States.ATTACK:
			attack(event)
		else:
			movement(event)
	elif event.is_action_pressed("move") and inMouse:
		selected = true
		parent.selected.selected = false
		for marker in parent.selected.markers:
			marker.queue_free()
			markers.clear()
		parent.selected = self
		
func attack(event):
	#if is_instance_valid(target) && target.danger && event.is_action_pressed("move"):
		
		
	pass
func movement(event):
	if currentMove > 0:
			for dir in inputs.keys():
				if event.is_action_pressed(dir)  :
					var currentPos = position
					#this moves the peice if there isn't a collision
					var collision = move_and_collide(inputs[dir] * tilesize *2)
					if !is_instance_valid(collision):
						currentMove -= 1
						
						#inserts position for the tail segments
						path.insert(0, position)
						if path.size() > attributes.maxSize +1:
							path.pop_back()
						#adds a new tailsegment
						if followers.size() < attributes.maxSize:
							add_follower()
						update_followers()
						update_move_options()
					else:
						#prevents weird movement into walls
						position = currentPos
	else :
		current_state = States.ATTACK

func update_move_options():
	var moves = 0
	var text = ""
	if current_state == States.MOVE:
		text = preload("res://marker.png")
		moves = currentMove
	elif current_state == States.ATTACK:
		text = preload("res://att_marker.png")
		moves = attributes.attackRange
	for marker in markers:
		marker.queue_free()
	markers.clear()
	# Loop through a diamond-shaped pattern based on the number of moves
	for x in range(-moves, moves + 1):
		for y in range(-moves, moves + 1):
			if abs(x) + abs(y) <= moves:
				if  abs(x) + abs(y) !=0:
					var area = Area2D.new()
					var marker = Sprite2D.new()
					marker.texture = text
					marker.position = Vector2(x*tilesize*2, y*tilesize*2)
					area.add_child(marker)
					add_child(area)
					markers.append(marker)
									
					### Add a collision shape to the area
					if current_state == States.ATTACK:
						var collision_shape = CollisionShape2D.new()
						var shape = RectangleShape2D.new()
						shape.extents = Vector2(tilesize, tilesize)
						collision_shape.shape = shape
						collision_shape.position = marker.position
						#area.add_child(collision_shape)
						$hurtbox.add_child(collision_shape)
						# Connect signal to detect collision
						$hurtbox.connect("body_entered", self._on_area_body_entered)
						$hurtbox.connect("body_exited", self._on_area_body_exited)
					elif is_instance_valid(area):
						for n in $hurtbox.get_children():
							$hurtbox.remove_child(n)
							n.queue_free()
					add_child(area)
					markers.append(marker)

# Signal callback function to handle collisions

func add_follower():
	var new_follower = follower_scene.instantiate()
	new_follower.change_sprite('res://'+attributes.name+'_tail.png')
	
	new_follower.setText(followers.size())
	new_follower.add_to_group(attributes.group)
	add_child(new_follower)
	followers.append(new_follower)
	updateParent(new_follower)
	# Update the position immediately to prevent initial overlap
	if path.size() >= followers.size():
		new_follower.global_position = path[followers.size() - 1]

func update_followers(): 
	
	for i in range(followers.size()):
		if path.size() > i + 1 && is_instance_valid(followers[i]):  # +1 because the first position is for the player itself
			followers[i].global_position = path[i + 1]
			followers[i].setText(i)

func _on_turn_timeout():
	$turn.stop()
	currentMove = attributes.maxMove
	current_state = States.MOVE

func _on_body_entered(body):
	if body.is_in_group("Player"):
		players_in_range.append(body)
		for bod in body.get_children():
			_on_body_entered(bod)
	if body.is_in_group("Enemy"):
		enems_in_range.append(body)
		for bod in body.get_children():
			_on_body_entered(bod)

func get_nearest_player():
	var nearest_player = null
	var nearest_dist = 1e10
	for player in players_in_range:
		var dist = global_position.distance_to(player.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_player = player
	return nearest_player
	
func _on_area_body_entered(body):
	if !body.is_in_group("tail") && body.is_in_group("enemy") && body.danger:
		target = body
		
func _on_area_body_exited(body):
		target =null


func _on_hitbox_input_event(viewport, event, shape_idx):
	if event.is_action_pressed('move'):
		pressed = true
	else:
		pressed = false
		
func delete(segs):
	
	var l = 0
	var s = 0
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
		await followers[index].play_deletion_animation()
		followers.erase(followers[index])
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
	material = $Sprite2D.material 
	if material is ShaderMaterial:
		material.set_shader_parameter("width", 4.0) 


func _on_area_2d_mouse_exited():
	inMouse = false
	material = $Sprite2D.material  
	if material is ShaderMaterial:
		material.set_shader_parameter("width", 0.0)  # Disable outline
