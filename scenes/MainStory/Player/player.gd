extends CharacterBody2D

class_name Player

@onready var hitbox_area = $HitboxComponent

var doubleTapTimers = {
	"left": 0.0,
	"right": 0.0,
	"up": 0.0,
	"down": 0.0,
}

var currentSpeed = 0
var dashDirection = Vector2.ZERO

# player stats
var strengthBuff: float = 0.0
var healthBuff: float = 0.0
var speedBuff: float = 0.0
var energyBuff: float = 0.0
var defBuff: float = 0.0
var critDamageBuff: float = 0.0
var critChanceBuff: float = 0.0

@export var inventory: Inventory

var playerPos = Vector2.ZERO

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	if Input.is_action_just_pressed("attack"):
		print("this is true")
		perform_attack()

func handle_movement(delta):
	var direction = Vector2.ZERO
	currentSpeed = 100
	#if isHurt:
		#return
	#if canMove:
		#currentSpeed = speedBuff
	#
	#if isDashing:
		#velocity = dashDirection * DASH_SPEED
		#move_and_slide()
	#else:
		#for dir in doubleTapTimers.keys():
			#if doubleTapTimers[dir] > 0:
				#doubleTapTimers[dir] -= delta
				
		# movements directions
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
		playerPos = direction
	if Input.is_action_pressed("ui_left"):
		print("hbda")
		direction.x -= 1
		playerPos = direction
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
		playerPos = direction
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
		playerPos = direction
	
	# animated sprites
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * currentSpeed
		move_and_slide()
	
func perform_attack():
	for area in hitbox_area.get_overlapping_areas():
		# Check if the area is a HitboxComponent
		if area is HitboxComponent:
			print("found hitbox")

			# Create an Attack instance
			var attack = Attack.new()
			attack.attack_damage = 100.0
			attack.knockback_force = 10.0
			attack.stun_time = 0.3

			# Pass the attack data into the hitbox's damage() function
			area.damage(attack)

			print("damage applied to enemy hitbox")
