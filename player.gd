extends CharacterBody3D

class_name Player

signal health_changed(value)

const SPEED = 5.0
const JUMP_VELOCITY = 6
var mouse_sensitivity = 0.01

var max_health = 3
var health = max_health

@onready var raycast: RayCast3D = $CameraPivot/RayCast3D
@onready var gun_hand: Node3D = $CameraPivot/Gun
@onready var pistol: Node3D = $CameraPivot/Gun/Pistol

@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var camera_pivot: Node3D = $CameraPivot

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	if !is_multiplayer_authority():
		return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true

func _physics_process(delta: float) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and Input.is_action_just_pressed("shoot"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and Input.is_action_just_pressed("nofocus"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if !is_multiplayer_authority():
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	if Input.is_action_just_pressed("shoot") && pistol.animation_player.current_animation != "shoot":
		play_shoot.rpc()
		if raycast.is_colliding() and raycast.get_collider() is Player:
			
			var player_hit: Player = raycast.get_collider()
			player_hit.hurt.rpc_id(player_hit.get_multiplayer_authority())

@rpc("call_local")
func play_shoot():
	pistol.shoot()

@rpc("any_peer")
func hurt():
	health -= 1
	if health <=0:
		health = max_health
		global_position = Vector3.ZERO
	
	health_changed.emit(health)

func _unhandled_input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x*mouse_sensitivity)
		camera_pivot.rotate_x(-event.relative.y*mouse_sensitivity)
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, deg_to_rad(-70), deg_to_rad(50))


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name =="shoot":
		$AnimationPlayer.play("RESET")
