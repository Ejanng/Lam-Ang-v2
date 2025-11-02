extends Area2D
signal all_enemies_defeated

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"
@export var auto_trigger: bool = false
@export var barriers: Array[StaticBody2D] = []
@export var enemy_group1: String = "dark_forest_enemies"

var has_triggered: bool = false
var dialogue_active: bool = false

func _ready() -> void:
	for barrier in barriers:
		if barrier:
			barrier.visible = false
			barrier.set_collision_layer_value(1, false)  # Disable collision
			barrier.set_collision_mask_value(1, false)
	
	if auto_trigger:
		body_entered.connect(_on_body_entered)
		
func _on_body_entered(body: Node2D) -> void:
	# Only trigger once and ignore repeated space presses
	if has_triggered or dialogue_active:
		print("Dialogue already running or triggered. Ignoring.")
		return

	if body.is_in_group("player") or body.name == "Lam-Ang":
		print("Player entered trigger zone.")
		has_triggered = true
		
		for barrier in barriers:
			if barrier:
				barrier.visible = true
				barrier.set_collision_layer_value(1, true)  # Enable collision
				barrier.set_collision_mask_value(1, true)
		
		_start_enemy_check()
		
		action()
	else:
		print("Non-player entered; ignoring.")

func _start_enemy_check() -> void:
	# Wait a frame to ensure everything is set up
	await get_tree().process_frame
	_check_enemies()

func _check_enemies() -> void:
	# Check if any enemies remain
	var enemies = get_tree().get_nodes_in_group(enemy_group1)
	print("Enemies remaining: ", enemies.size())
	
	if enemies.size() == 0:
		print("All enemies defeated! Opening barriers...")
		_open_barriers()
	else:
		# Check again after a short delay
		await get_tree().create_timer(0.5).timeout
		_check_enemies()

func _open_barriers() -> void:
	# Disable and hide all barriers
	for barrier in barriers:
		if barrier:
			barrier.visible = false
			barrier.set_collision_layer_value(1, false)
			barrier.set_collision_mask_value(1, false)
	
	all_enemies_defeated.emit()
	print("Barriers opened!")
	
func action() -> void:
	var parent_name = get_parent().name
	var player = get_tree().get_root().find_child("Lam-Ang", true, false)

	dialogue_active = true  # Prevent multiple triggers while active
	
	if player:
		print("Disabling player movement.")
		player.can_move = false
		player.velocity = Vector2.ZERO
		player.set_physics_process(false)

	# Dynamically assign dialogue start node based on parent name
	match parent_name:
		"Namongan":
			dialogue_start = "namongan_start"
		"WoundedVillager":
			dialogue_start = "wounded_villager_start"
		"InternalMonologue1":
			dialogue_start = "internal_monologue_1_start"
		"IgorotVillage":
			dialogue_start = "igorot_village_start"
		"NamonganMain1":
			dialogue_start = "lam_ang_scene1_start"
		"Act1Scene2":
			dialogue_start = "lam_ang_scene2_start"
		"Act1Scene3":
			dialogue_start = "lam_ang_scene3_start"
		"Act2Scene1":
			dialogue_start = "act2_scene1_homecoming_start"
		"Act2Scene2":
			dialogue_start = "act2_scene2_1_travel_start"
		"Act2Scene3":
			dialogue_start = "act2_scene3_suitors_start"
		"Act2Scene4":
			dialogue_start = "act2_scene4_meeting_ines"
		"Act3Scene1":
			dialogue_start = "act3_scene1_rarang_call"
		"Act3Scene2":
			dialogue_start = "act3_scene2_shore_dive"
		"Act3Scene2_1":
			dialogue_start = "act3_scene2_1_shore_dive"
		"Epilogue":
			dialogue_start = "epilogue_nalbuan_return"
	
	# Start the dialogue
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)

	await DialogueManager.dialogue_ended

	if player:
		print("Re-enabling player movement.")
		player.can_move = true
		player.set_physics_process(true)
		
		#for barrier in barriers:
			#if barrier:
				#barrier.queue_free()

	dialogue_active = false
	print("Dialogue finished.")
