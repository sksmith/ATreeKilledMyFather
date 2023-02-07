extends StaticBody2D

export var hit_points = 5
signal heart_tree_died()

func hit(damage: int):
	hit_points -= damage
	
	if hit_points <= 0:
		emit_signal("heart_tree_died")

func target():
	$HeartTreeSprite.visible = false
	$HeartTreeTargetedSprite.visible = true

func un_target():
	$HeartTreeSprite.visible = true
	$HeartTreeTargetedSprite.visible = false

func is_dead():
	return hit_points <= 0
