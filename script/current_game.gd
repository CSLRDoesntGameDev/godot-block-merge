extends Node

signal clear

var total_score: int
var highest_po2: int :
	set(value):
		highest_po2 = value
		if is_instance_valid(game_scene):
			game_scene.notify_new_po2(get_po2_value(value))

var game_scene: Control

func get_po2_value(po2: int) -> int:
	return 2 ** clamp(po2, 1, 1024)

func game_over() -> void:
	total_score = 0
	highest_po2 = 0
	clear.emit()
