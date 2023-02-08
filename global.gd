extends Node

const LUMBERJACK = 1
const HEARTTREE = 2

var winner = 0

var heart_tree_player_id = 1
var lumberjack_player_id = 1

func is_mp():
	return get_tree().has_network_peer()
