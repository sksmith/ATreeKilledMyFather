extends Area2D


export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var can_plant_tree = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size


func _process(delta):
	var velocity = Input.get_vector("f_move_left", "f_move_right", "f_move_up", "f_move_down")
	velocity = velocity * speed
	
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

#	if velocity.length() > 0:
#		velocity = velocity.normalized() * speed
#		$AnimatedSprite.play()
#	else:
#		$AnimatedSprite.stop()


func _on_ForestCursor_area_entered(area):
	_set_can_plant()


func _on_ForestCursor_area_exited(area):
	_set_can_plant()

func _set_can_plant():
	if _can_plant():
		can_plant_tree = true
		$AnimatedSprite.play("plant")
	else:
		can_plant_tree = false
		$AnimatedSprite.play("no")
	
func _can_plant():
	var areas = get_overlapping_areas()
	var in_planting_range = false
	var in_tree = false
	for a in areas:
		if a.is_in_group("tree"):
			in_tree = true
			break
		if a.is_in_group("plant_range"):
			in_planting_range = true

	return in_planting_range && !in_tree

