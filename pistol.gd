extends Node3D

class_name Pistol
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var flash: CPUParticles3D = $pivot/CPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func shoot():
	animation_player.play("shoot")
	flash.restart()
