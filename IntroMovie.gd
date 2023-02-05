extends Node

func _ready():
	$IntroScreen.play("default")
	#yield(get_tree().create_timer(0.01), "timeout")
	$IntroMusic.play()

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		get_tree().change_scene("res://Title.tscn")
