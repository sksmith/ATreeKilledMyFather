extends Node2D

#export(NodePath) var my_tree
#export(NodePath) var my_planting_range
#
#var my_tree_node
#var my_planting_range_node
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass
#	my_tree_node = get_node(my_tree)
#	my_planting_range_node = get_node(my_planting_range)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Tree_tree_grown(tree):
	if tree == $Tree:
		$PlantingRange.visible = true
		$PlantingRange.monitorable = true
		print("my tree grew!")
