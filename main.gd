extends Node2D

@onready var tile_map = %TileMap
var tile_pos = Vector2()
var selected =null
var PlayRunes = []
var EnemRunes = []
enum States { PREP, GAME, PAUSE }
# Called when the node enters the scene tree for the first time.
func _ready():
	
	for e in get_children():
		if e.is_in_group('Player'):
			PlayRunes.append(e)
		elif  e.is_in_group('enemy'):
			EnemRunes.append(e)
	selected = PlayRunes[0]
	selected.selected = true
	tile_pos = tile_map.local_to_map(get_local_mouse_position())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_instance_valid(selected):
		selected = PlayRunes[0]
	#print(EnemRunes)
	if selected.current_state == 1:
		for e in EnemRunes:
			if((selected.position - e.position).length()/32 < selected.attributes.attackRange*32):
				if(e.pressed):
					print(e)
					e.delete(selected.attributes.attackPower)
					e.pressed = false
					selected.current_state = 0
		
	pass


