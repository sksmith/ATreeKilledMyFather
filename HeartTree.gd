extends StaticBody2D

export var hit_points = 50
signal heart_tree_died()

func hit(damage: int):
	hit_points -= damage
	
	if hit_points <= 0:
		emit_signal("heart_tree_died")
