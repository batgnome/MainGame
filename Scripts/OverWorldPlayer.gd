extends CharacterBody3D

@export
var SPEED = 5.0

@export var camera : Camera3D
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("pause") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = ( Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = ray_origin+ camera.project_ray_normal(mouse_pos) * 500
	var ray_query = PhysicsRayQueryParameters3D.create(ray_origin,ray_direction)

	#ray_query.collide_with_bodies = true

	var space_state = get_world_3d().direct_space_state
	var ray_result = space_state.intersect_ray(ray_query)

	if(!ray_result.is_empty()):
		look_at(ray_result.position)
			# if ray_result.collider != self:
			# 	var target_position = ray_result.position
			# 	target_position.y += 1.0  # Adjust this value to point 1 meter above the hit point
			# 	look_at(target_position)
