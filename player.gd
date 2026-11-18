extends CharacterBody3D

class_name Player

signal health_changed(value)

const SPEED = 5.0
const JUMP_VELOCITY = 6
var mouse_sensitivity = 0.01

var max_health = 3
var health = max_health
var gun_damage = 1

var pistol_file = preload("res://pistol.tscn")
var shotgun_file = preload("res://shotgun.tscn")


var chosen_gun: Global.Choosable_guns
var gun_file: PackedScene
@onready var raycast: RayCast3D
@onready var gun_hand: Node3D = $CameraPivot/Gun
@onready var pistol: Node3D = $CameraPivot/Gun/Pistol

@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var camera_pivot: Node3D = $CameraPivot

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())
	Global.playerlist.append(str(name).to_int())
	print(Global.playerlist)
	#chosen_gun = Global.Choosable_guns.PISTOL

func _ready() -> void:
	match chosen_gun:
		Global.Choosable_guns.PISTOL:
			self.gun_file = pistol_file
		Global.Choosable_guns.SHOTGUN:
			self.gun_file = shotgun_file
	if !is_multiplayer_authority():
		print("adding synced gun(?) idk tho lolol")
		for i in get_tree().root.get_child(1).get_children():
			if str(i.name).to_int() in Global.playerlist:
				print("aaaaaaa")
				if i.is_multiplayer_authority():
					continue
				var playera = i
				
				var g: Node3D = playera.gun_file.instantiate()
				print("aaaaaaaaaaaaaaaaaaaaaaaa: ", g.name)
				gun_damage = g.damage
				$CameraPivot/Gun.add_child(g)
				print("gun added. name is ", g.name)
				pistol = $CameraPivot/Gun.get_child(0)
				raycast = pistol.raycast
		#var playera = get_tree().root.get_child(1).get_node_or_null(str(Global.playerlist.find(str(name).to_int())))
		return
	match chosen_gun:
		Global.Choosable_guns.PISTOL:
			var g: Pistol = pistol_file.instantiate()
			self.gun_file = pistol_file
			gun_damage = g.damage
			$CameraPivot/Gun.add_child(g)
			print("pistol")
		Global.Choosable_guns.SHOTGUN:
			var g: Shotgun = shotgun_file.instantiate()
			self.gun_file = shotgun_file
			gun_damage = g.damage
			$CameraPivot/Gun.add_child(g)
			print("shotgunnnn yayayayay")
	pistol = $CameraPivot/Gun.get_child(0)
	raycast = pistol.raycast
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	print(chosen_gun)
	camera.current = true

func _physics_process(delta: float) -> void:
	#print("chosen gun of name, ",self.name," is ", chosen_gun)
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
			player_hit.hurt.rpc_id(player_hit.get_multiplayer_authority(), self.gun_damage)

@rpc("call_local")
func play_shoot():
	pistol.shoot()
	#velocity += camera_pivot.basis.x * 1000

@rpc("any_peer")
func hurt(d):
	health -= d
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
