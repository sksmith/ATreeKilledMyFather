extends Area2D

var targeted_image = preload("res://assets/lumberjack/tree_phase-3-targeted.png")
var not_targeted_image = preload("res://assets/lumberjack/tree_phase-3.png")
export var hit_points = 5

func _ready():
	$TreeSprite.texture = not_targeted_image

#func _on_ShittyTree_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
#	if area.name == "LumberjackReticle":
#		$TreeSprite.texture = targeted_image
#
#func _on_ShittyTree_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
#	if area.name == "LumberjackReticle":
#		$TreeSprite.texture = not_targeted_image

func target():
	$TreeSprite.texture = targeted_image

func un_target():
	$TreeSprite.texture = not_targeted_image

func hit(damage: int):
	hit_points -= damage
	if hit_points <= 0:
		queue_free()
