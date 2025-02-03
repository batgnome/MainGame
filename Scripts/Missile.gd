extends Node3D  # Use Area3D if you don’t want physics-based movement

@export var speed := 10.0  # Speed of the missile
@export var lifetime := 3.0  # How long the missile lasts before disappearing

var direction = Vector3.ZERO  # The direction of movement

func _ready():
	# Destroy after `lifetime` seconds
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta):
	print(direction)
	if direction != Vector3.ZERO:
		position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):  # Adjust based on your enemy detection logic
		body.queue_free()  # Destroy enemy (for testing)
		queue_free()  # Destroy missile


func _on_area_3d_body_entered(body):
	print(body.get_groups())
	if body.is_in_group("enemy"):  # Adjust based on your enemy detection logic
		body.queue_free()  # Destroy enemy (for testing)
		queue_free()  # Destroy missile
