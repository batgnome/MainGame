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
var alreadyRun = 0
func init():
	for rune in detection_area.get_children():
		_on_body_entered(rune)
	super.init()
	currentMove = 0
	$turn.start(attributes.speed)
	#debugSeed()

func _input(event):
	if event.is_action_pressed("move") == false:
		return

func _physics_process(_delta: float) -> void:
	#print($EnemMoveSpeed.get_time_left())
	
	debugSeed()
	#movement(time)
	
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
	if $EnemMoveSpeed.time_left <= 0.5:
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
		#print("time")
		$EnemMoveSpeed.start(0.7)

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
func update_move_options():
	pass

func debugSeed():
	if alreadyRun == 0:
		var arr=['up','up','left','left','up']
		DebugMovement(arr)
		alreadyRun = 1
	
func DebugMovement(arr):
	for i in arr:
		for dir in inputs.keys():
			if i == dir:
				#print(inputs[dir])
				var currentPos = position
				#this moves the peice if there isn't a collision
				var collision = move_and_collide(inputs[dir] * tilesize *2)
				
				
					
				#inserts position for the tail segments
				path.insert(0, position)
				if path.size() > attributes.maxSize +1:
					path.pop_back()
				#adds a new tailsegment
				if followers.size() < attributes.maxSize:
					add_follower()
				update_followers()
				#print(position)
				#else:
					##prevents weird movement into walls
					#position = currentPos

	
