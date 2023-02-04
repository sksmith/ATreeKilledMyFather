extends Node

var score

func _ready():
	new_game()
	randomize()

func new_game():
	$Lumberjack.start($LumberjackSpawnPoint.position)
