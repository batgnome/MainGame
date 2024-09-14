extends Node2D

@onready var tile_map = %TileMap
var tile_pos = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	tile_pos = tile_map.local_to_map(get_local_mouse_position())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


