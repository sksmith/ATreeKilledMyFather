extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func enable_planting():
	visible = true
	$CollisionShape2D.set_deferred("disabled", false)
