extends Node

export(NodePath) var lumberjack
export(NodePath) var lumberjack_spawn

var lumberjack_node
var lumberjack_spawn_node

func _ready():
	new_game()
	randomize()

func new_game():
	lumberjack_node = get_node(lumberjack)
	lumberjack_spawn_node = get_node(lumberjack_spawn)
	lumberjack_node.start(lumberjack_spawn_node.position)
	if $PlayTheme:
		$PlayTheme.play()

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _on_HeartTree_heart_tree_died():
	get_tree().paused = true
	
