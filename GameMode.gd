extends Control

const SERVER_PORT = 3000
const MAX_PLAYERS = 2

func _ready():
	pass # Replace with function body.

func _on_Local_pressed():
	get_tree().change_scene("res://Play-Test.tscn")

func _on_Host_pressed():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer
	setup_network_callbacks()
#	get_tree().change_scene("res://Play.tscn")
	$WaitingForPlayer.visible = true
	$Local.visible = false
	$Host.visible = false
	$Join.visible = false

func _on_Join_pressed():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client("localhost", SERVER_PORT)
	get_tree().network_peer = peer
	setup_network_callbacks()

func setup_network_callbacks():
	var error = get_tree().connect("network_peer_connected", self, "_network_peer_connected")
	if error != OK:
		print(str(error))
	
	error = get_tree().connect("network_peer_disconnected", self, "_network_peer_disconnected")
	if error != OK:
		print(str(error))
	
	error = get_tree().connect("connected_to_server", self, "_connected_ok")
	if error != OK:
		print(str(error))
		
	error = get_tree().connect("connection_failed", self, "_connection_failed")
	if error != OK:
		print(str(error))
	
	error = get_tree().connect("server_disconnected", self, "_server_disconnected")
	if error != OK:
		print(str(error))

func _network_peer_connected(id: int):
	if is_network_master():
		global.lumberjack_player_id = id
	get_tree().set_refuse_new_network_connections(true)
	get_tree().change_scene("res://Play-Test.tscn")
	
func _network_peer_disconnected(id: int):
	print("Player " + str(id) + " has disconnected")
	
func _connected_ok():
	if !is_network_master():
		global.lumberjack_player_id = get_tree().get_network_unique_id()
	print("_connected_ok called")

func _connection_failed():
	print("_connection_failed called")
	
func _server_disconnected():
	print("_server_disconnected called")
