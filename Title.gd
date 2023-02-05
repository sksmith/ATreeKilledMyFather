extends Node

func _ready():
	$TitleTheme.play()

func _process(delta):
	if Input.is_action_pressed("attack"):
		get_tree().change_scene("res://Play.tscn")
