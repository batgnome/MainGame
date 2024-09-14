extends CharacterBody2D

var attributes={"name":"tails"}
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("tail")
	name = "tail"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(self.get_groups())
	pass

func setText(text):
	%node_number.text =  str(text)

func change_sprite(sprite):
	$Sprite2D.texture = load(sprite)
