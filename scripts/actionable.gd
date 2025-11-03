extends Area2D
signal all_enemies_defeated

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"
@export var auto_trigger: bool = false
@export var barriers: Array[StaticBody2D] = []
@export var barrier_mappings: Dictionary[String, Array] = {}
@export var enemy_group1: String = "dark_forest_enemies"
#@export var bandit_group: String = "bandit_enemies"
@export var nodes_to_hide: Array[String] = ["Act2Scene1", "Act3Scene1", "Epilogue"]

# NEW: Dictionary to map parent names to their barrier node paths
# Key: String (parent name), Value: Variant (can be String path or Array of String paths)

var has_triggered: bool = false
var dialogue_active: bool = false

func _ready() -> void:
	barrier_mappings["Act1Scene3"] = ["../../NamonganMain1/BarrierSouth"]
	_hide_nodes()
	
	for barrier in barriers:
		if barrier:
			barrier.visible = false
			barrier.set_collision_layer_value(1, false)
			barrier.set_collision_mask_value(1, false)
	
	if auto_trigger:
		body_entered.connect(_on_body_entered)
		
# Function to hide multiple nodes
func _hide_nodes() -> void:
	var grandparent = get_parent().get_parent()
	
	for node_name in nodes_to_hide:
		var node = grandparent.get_node_or_null(node_name)
		if node:
			node.process_mode = Node.PROCESS_MODE_DISABLED
			# Hide all children that are CanvasItems
			_hide_children_recursive(node)
			print("Hidden: ", node_name)
		else:
			print("Could not find node: ", node_name)

# Recursively hide all CanvasItem children
func _hide_children_recursive(node: Node) -> void:
	if node is CanvasItem:
		node.visible = false
	
	for child in node.get_children():
		_hide_children_recursive(child)

# Function to show a specific node later
func _show_node(node_name: String) -> void:
	var grandparent = get_parent().get_parent()
	var node = grandparent.get_node_or_null(node_name)
	if node:
		node.process_mode = Node.PROCESS_MODE_INHERIT
		# Show all children that are CanvasItems
		_show_children_recursive(node)
		print("Shown: ", node_name)

# Recursively show all CanvasItem children
func _show_children_recursive(node: Node) -> void:
	if node is CanvasItem:
		node.visible = true
	
	for child in node.get_children():
		_show_children_recursive(child)

# NEW: Function to open specific barriers by parent name
func _open_barriers_for_parent(parent_name: String) -> void:
	if barrier_mappings.has(parent_name):
		var barrier_paths = barrier_mappings[parent_name]
		
		# Handle both single path (String) and multiple paths (Array)
		if barrier_paths is String:
			_open_single_barrier(barrier_paths)
		elif barrier_paths is Array:
			for barrier_path in barrier_paths:
				_open_single_barrier(barrier_path)
		
		print("Opened barriers for: ", parent_name)
	else:
		print("No barrier mapping found for: ", parent_name)

# NEW: Helper function to open a single barrier by path
func _open_single_barrier(barrier_path: String) -> void:
	var barrier = get_node_or_null(barrier_path)
	if barrier and barrier is StaticBody2D:
		barrier.visible = false
		barrier.set_collision_layer_value(1, false)
		barrier.set_collision_mask_value(1, false)
		print("Opened barrier: ", barrier_path)
	else:
		print("Could not find barrier: ", barrier_path)
		
func _on_body_entered(body: Node2D) -> void:
	if has_triggered or dialogue_active:
		print("Dialogue already running or triggered. Ignoring.")
		return

	if body.is_in_group("player") or body.name == "Lam-Ang":
		print("Player entered trigger zone.")
		has_triggered = true
		
		for barrier in barriers:
			if barrier:
				barrier.visible = true
				barrier.set_collision_layer_value(1, true)
				barrier.set_collision_mask_value(1, true)
		
		# NEW: Open barriers based on parent name when player enters
		var parent_name = get_parent().name
		_open_barriers_for_parent(parent_name)
		
		_start_enemy_check()
		action()
	else:
		print("Non-player entered; ignoring.")

func _hide_specific_node(node_name: String) -> void:
	var grandparent = get_parent().get_parent()
	var node = grandparent.get_node_or_null(node_name)
	if node:
		node.process_mode = Node.PROCESS_MODE_DISABLED
		_hide_children_recursive(node)
		print("Hidden node on entry: ", node_name)
	else:
		print("Could not find node to hide: ", node_name)
	
func _start_enemy_check() -> void:
	await get_tree().process_frame
	_check_enemies()

func _check_enemies() -> void:
	var enemies = get_tree().get_nodes_in_group(enemy_group1)
	print("Enemies remaining: ", enemies.size())
	
	if enemies.size() == 0:
		print("All enemies defeated! Opening barriers...")
		_open_barriers()
	else:
		await get_tree().create_timer(0.5).timeout
		_check_enemies()

func _open_barriers() -> void:
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

	dialogue_active = true
	
	if player:
		print("Disabling player movement.")
		player.can_move = false
		player.velocity = Vector2.ZERO
		player.set_physics_process(false)

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
	
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)
	await DialogueManager.dialogue_ended
	
	match parent_name:
		"Act1Scene3":
			_show_node("Act2Scene1")
			_hide_specific_node("NamonganMain1")
		"Act2Scene4":
			_show_node("Act3Scene1")
		"Act3Scene2_1":
			_show_node("Act3Scene2_1")
		
		
	if player:
		print("Re-enabling player movement.")
		player.can_move = true
		player.set_physics_process(true)

	dialogue_active = false
	print("Dialogue finished.")
