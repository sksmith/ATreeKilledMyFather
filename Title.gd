extends Node

func _ready():
	$TitleTheme.play()

func _process(delta):
	if Input.is_action_just_pressed("any_confirm"):
		get_tree().change_scene("res://GameMode.tscn")
