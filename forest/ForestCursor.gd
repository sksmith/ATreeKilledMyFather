extends Area2D

export var cursor_speed = 400 # How fast the player will move (pixels/sec).
export var fine_cursor_speed = 200
export(Resource) var tree_resource
export(NodePath) var tree_parent_node
export(float) var planting_cooldown: float = 1.5
export var seed_drop_sounds: Array

signal cabin_destroyed()

var r = RandomNumberGenerator.new()
var screen_size # Size of the game window.
var can_plant_tree = false
var tree_planting_node
var on_cooldown = false
var prev_velocity = Vector2.ZERO # Stored for puppet-side prediction

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	set_network_master(global.heart_tree_player_id)
	
	var sprite_frames = $AnimatedSprite.get_sprite_frames()
	var cooldown_frames = sprite_frames.get_frame_count("cooldown")
	var cooldown_speed = cooldown_frames / float(planting_cooldown)
	
	sprite_frames.set_animation_speed("cooldown", cooldown_speed)
	if tree_parent_node:
		tree_planting_node = get_node(tree_parent_node)

func _process(delta):
	
	if global.is_mp() && !is_network_master():
		if prev_velocity != Vector2.ZERO:
			position += prev_velocity * delta
			position.x = clamp(position.x, 0, screen_size.x)
			position.y = clamp(position.y, 0, screen_size.y)
		
		_set_can_plant()
		return

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
	
	if global.is_mp():
		rpc("_update_position", position, velocity)
	
	_set_can_plant()

puppet func _update_position(pos: Vector2, vel: Vector2):
	position = pos
	prev_velocity = vel

func _try_plant_tree():
	if can_plant_tree:
		_do_plant_tree()
		if global.is_mp():
			rpc("_do_plant_tree")
	else:
		print("nope! can't plant")

puppetsync func _do_plant_tree():
	if _is_planting_on_cabin():
		emit_signal("cabin_destroyed")
		pass
	
	can_plant_tree = false
	play_plant_seed_sound()
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

func _is_planting_on_cabin():
	var areas = get_overlapping_areas()
	for a in areas:
		if a.is_in_group("cabin"):
			return true

	return false

func play_plant_seed_sound():
	$PlantSeedSound.stream = seed_drop_sounds[r.randi() % seed_drop_sounds.size()]
	$PlantSeedSound.play()
