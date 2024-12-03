extends Node2D

@onready var tile_map = %TileMap
var tile_pos = Vector2()
var selected =null
# Called when the node enters the scene tree for the first time.
func _ready():
	selected = get_child(1)
	
	tile_pos = tile_map.local_to_map(get_local_mouse_position())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if selected.current_state == 1:
		if((selected.position - get_child(2).position).length()/32 < selected.attributes.attackRange):
			if(get_child(2).pressed):
				get_child(2).delete(selected.attributes.attackPower)
				get_child(2).pressed = false
				selected.current_state = 0
		
	pass


