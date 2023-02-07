extends Node

func _process(delta):
	if global.winner == global.HEARTTREE:
		$"Heart-Tree-Wins".visible = true
		$"Lumberjack-Wins".visible = false
	elif global.winner == global.LUMBERJACK:
		$"Heart-Tree-Wins".visible = false
		$"Lumberjack-Wins".visible = true
	
	if Input.is_action_pressed("any_confirm"):
		get_tree().change_scene("res://Title.tscn")
