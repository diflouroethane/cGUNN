extends Node3D

class_name Shotgun
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var flash: CPUParticles3D = $pivot/CPUParticles3D
@onready var raycast = $RayCast3D
var damage = 3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("RESET")
	print("damage of gun is:", get_parent().get_parent().get_parent().gun_damage)
	print("setting gun damage of player with name ", get_parent().get_parent().get_parent().name, " to ", damage)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func shoot():
	animation_player.play("shoot")
	flash.restart()
