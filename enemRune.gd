extends "res://Rune.gd"
@export var player = Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D

func set_attributes():
	add_to_group("enemy")
	attributes = {
	"name": "seeker",
	"health": 2,
	"maxSize": 3,
	"defense": 2,
	"maxMove": 3,
	"attackRange": 1,
	"attackPower": 2,
	"speed": 3,
	"sprite":"res://enem.png",
	"group":"enemy"
}
var time := 0.0
@onready var detection_area = get_parent()
@onready var tilemap = %TileMap
var AStarGrid : AStarGrid2D
func init():
	AStarGrid = AStarGrid2D.new()
	AStarGrid.region = tilemap.get_used_rect()
	AStarGrid.cell_size=Vector2i(16,16)
	AStarGrid.diagonal_mode =AStarGrid2D.DIAGONAL_MODE_NEVER
	AStarGrid.update()
	for rune in detection_area.get_children():
		_on_body_entered(rune)
	super.init()
	currentMove = 0
	$turn.start(attributes.speed)

func _input(event):
	
	if event.is_action_pressed("move") == false:
		return
	#print(AStarGrid)
	var id_path = AStarGrid.get_id_path(
		tilemap.local_to_map(global_position),
		tilemap.local_to_map(get_global_mouse_position())
	)
	#print(tilemap.local_to_map(get_global_mouse_position()))
	#print(id_path)

func _physics_process(_delta: float) -> void:
	#var dir = to_local(nav_agent.get_next_path_position().normalized())
	#time += int(_delta*100)
	#velocity +=dir * 5
	#move_and_slide()
	movement(time)
	#this is the timer for the node
	$TurnTimer.set_value(($turn.get_time_left()/$turn.wait_time)*100)
	
	
	
	#this starts the timer 
	if current_state == States.ATTACK && $turn.time_left  <=0:
		$turn.start(attributes.speed)

func makepath():
	nav_agent.target_position = get_nearest_player().global_position
	
func _on_move_timeout():
	
	makepath()
	
func movement(time):
	if (int(time)% 30 == 0):
		if currentMove > 0:
				for dir in inputs.keys():
					if get_direction_move() == dir:
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
						else:
							#prevents weird movement into walls
							position = currentPos
		else :
			current_state = States.ATTACK

func _unhandled_input(event):
	pass
	
func get_direction_move():
	
	var nearest_player = get_nearest_player()
	var direction = nearest_player.global_position
	#print(direction)
	var position = ''
	if direction.x - global_position.x > 0:
		position = 'right'
	elif direction.x - global_position.x < 0:
		position =  'left'
	elif direction.y - global_position.y <0:
		position =  'up'
	elif direction.y - global_position.y >0:
		position =  'down'

	return position		


	
