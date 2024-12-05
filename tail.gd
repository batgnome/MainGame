extends CharacterBody2D

var attributes={"name":"tails"}
var parent = null
var pressed = false
# Called when the node enters the scene tree for the first time.
func _ready():
	parent = get_parent()
	add_to_group("tail")
	add_to_group(parent.get_group())
	#print(get_groups())
	name = "tail"
	
func _on_hitbox_input_event(viewport, event, shape_idx):
	if event.is_action_pressed('move'):
		print("click")
		pressed = true
	else:
		pressed = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(self.get_groups())
	pass

func setText(text):
	%node_number.text =  str(text)

func change_sprite(sprite):
	$Sprite2D.texture = load(sprite)
	
func delete(segs):
	parent.delete(segs)

func _on_hitbox_mouse_entered():
	print("entered")
	pass # Replace with function body.
