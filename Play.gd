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
	updateDebug()
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _on_HeartTree_heart_tree_died():
	global.winner = global.LUMBERJACK
	get_tree().change_scene("res://WinScreen.tscn")

func _on_ForestCursor_cabin_destroyed():
	global.winner = global.HEARTTREE
	get_tree().change_scene("res://WinScreen.tscn")

func updateDebug():
	if $DebugLabel == null:
		return
	
	if global.is_mp():
		var debugText = "Network Player Id: " + str(get_tree().get_network_unique_id()) + "\n"
		debugText += "Lumberjack Player Id: " + str(global.lumberjack_player_id) + "\n"
		debugText += "Heart Tree Player Id: " + str(global.heart_tree_player_id) + "\n"
		debugText += "Heart Tree Master: " + str(get_node("World/ForestCursor").get_network_master()) + "\n"
		debugText += "Lumberjack Master: " + str(get_node("World/YSort/Lumberjack").get_network_master())
		
		$DebugLabel.set_text(debugText)
	else:
		$DebugLabel.set_text("local")
