extends "res://Rune.gd"
@export var player = Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D

func set_attributes():
	add_to_group("enemy")
	attributes = {
	"name": "enemy",
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
var attacked = false
@onready var detection_area = get_parent()
@onready var tilemap = %TileMap
var enemSelected = false
func init():
	super.init()
	currentMove = 0
	$turn.start(attributes.speed)
	
func _unhandled_input(event):
	pass
	
func _physics_process(_delta: float) -> void:
	if enemSelected:
		$TurnTimer.set_value(($turn.get_time_left()/$turn.wait_time)*100)
		movement(time)
		
		#this is the timer for the node
		
		#this starts the timer 
		if current_state == States.ATTACK && $turn.time_left  <=0:
			var nearest_player = get_nearest_player()
			if((position-nearest_player.position).length()/64 <= attributes.attackRange and !attacked):
					nearest_player.delete(attributes.attackPower)
					attacked = true
					enemSelected = false
			$turn.start(attributes.speed)
			endTurn()
			

func endTurn():
	enemSelected = false
	attacked = false
	
func movement(time):
	
	if $EnemMoveSpeed.time_left <= 0.5:
		if currentMove > 0:
				for dir in inputs.keys():
					if get_direction_move() == dir:
						if is_in_range():
							current_state = States.ATTACK
							break;
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
							endTurn()
							
		else :
			current_state = States.ATTACK
			
			
		#print("time")
		$EnemMoveSpeed.start(1.0)
func is_in_range():
	var nearest_player = get_nearest_player()
	if((position-nearest_player.position).length()/64 <= attributes.attackRange):
		return true
	return false
	
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
	
func get_direction_move():
	
	var position = ''
	var nearest_player = get_nearest_player()
	if is_instance_valid(nearest_player):
		var direction = nearest_player.global_position
		#print(direction)
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
