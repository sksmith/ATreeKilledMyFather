extends Node2D

export var start_grown = false

func _ready():
	if start_grown:
		$Tree.set_phase($Tree.MAX_PHASE)

func _on_Tree_tree_grown(tree):
	if tree == $Tree:
		$PlantingRange.enable_planting()

func _on_Tree_tree_died(tree):
	if tree == $Tree:
		queue_free()
