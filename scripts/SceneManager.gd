extends Node

func change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)

func reload_current_scene() -> void:
	get_tree().reload_current_scene()

func quit_game() -> void:
	get_tree().quit()