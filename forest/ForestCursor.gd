extends Area2D


export var cursor_speed = 400 # How fast the player will move (pixels/sec).
export var fine_cursor_speed = 200
export(Resource) var tree_resource
export(NodePath) var tree_parent_node
export var planting_cooldown = 2
export var seed_drop_sounds: Array

var r = RandomNumberGenerator.new()
var screen_size # Size of the game window.
var can_plant_tree = false
var tree_planting_node
var on_cooldown = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	if tree_parent_node:
		tree_planting_node = get_node(tree_parent_node)

func _process(delta):
	var prepare_plant = Input.is_action_pressed("f_action")
	var do_plant = Input.is_action_just_released("f_action")
	
	if do_plant:
		_try_plant_tree()
		
	var speed = cursor_speed
	if prepare_plant:
		speed = fine_cursor_speed
	
	var velocity = Input.get_vector("f_move_left", "f_move_right", "f_move_up", "f_move_down")
	velocity = velocity * speed
	
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

	_set_can_plant()
#	if velocity.length() > 0:
#		velocity = velocity.normalized() * speed
#		$AnimatedSprite.play()
#	else:
#		$AnimatedSprite.stop()

func _try_plant_tree():
	if can_plant_tree:
		_do_plant_tree()
	else:
		print("nope! can't plant")

func _do_plant_tree():
	can_plant_tree = false
	var tree = tree_resource.instance()
	tree.position = position
	tree_planting_node.add_child(tree)
	_start_planting_cooldown()

func _start_planting_cooldown():
	on_cooldown = true
	$AnimatedSprite.play("cooldown")
	yield(get_tree().create_timer(planting_cooldown), "timeout")
	on_cooldown = false
	_set_can_plant()

func _on_ForestCursor_area_entered(_area):
	pass
	# _set_can_plant()

func _on_ForestCursor_area_exited(_area):
	pass
	# _set_can_plant()

func _set_can_plant():
	if on_cooldown:
		return

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

func play_plant_seed_sound():
	$PlantSeedSound.stream = seed_drop_sounds[r.randi() % seed_drop_sounds.size()]
	$PlantSeedSound.play()
