extends CharacterBody2D

class_name MeleeEnemy

@export var player: Node2D

func _ready():
	# Automatically find the player in the scene
	pass

func _physics_process(delta: float) -> void:
	move_and_slide()
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
