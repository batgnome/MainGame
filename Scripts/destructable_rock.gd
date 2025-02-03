extends Node3D


@export var enemSelected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	print(position)
	add_to_group("enemy")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_rock_body_body_entered(body):
	print(body)
