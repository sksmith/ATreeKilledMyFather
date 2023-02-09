extends KinematicBody2D

export var speed = 200 # How fast the player will move (pixels/sec).
export var attack_duration_ms = 0.5
export var chop_sounds: Array
export var grunt_sounds: Array
export var damage = 2

var r = RandomNumberGenerator.new()
var screen_size # Size of the game window.
var is_attacking = false
var current_attack_time = 0
var target_tree
var is_walking = false
var played_chop_sound = false
var prev_velocity = Vector2.ZERO # Stored for puppet-side prediction

func start(pos):
	print("network master for lumberjack=", global.lumberjack_player_id)
	set_network_master(global.lumberjack_player_id)
	position = pos
	show()
	$AnimatedSprite.play()

func _ready():
	screen_size = get_viewport_rect().size
	hide()

func _process(delta):
	update_target_tree()

func _physics_process(delta):
	if global.is_mp() && !is_network_master():
		position += prev_velocity * delta
		position.x = clamp(position.x, 0, screen_size.x)
		position.y = clamp(position.y, 0, screen_size.y)
		return
		
	if is_attacking:
		current_attack_time += delta
		
		if $AnimatedSprite.frame == 1 && target_tree != null:
			play_chop_sound()
		
		if current_attack_time >= attack_duration_ms:
			_end_attack()
			
			if target_tree != null:
				target_tree.hit(damage)
			
				if target_tree.is_dead():
					$TreeFall.play()
	else:
		var velocity = Input.get_vector("lj_move_left", "lj_move_right", "lj_move_up", "lj_move_down")

		if velocity == Vector2.ZERO:
			velocity = Input.get_vector("lj_aim_left", "lj_aim_right", "lj_aim_up", "lj_aim_down")
		
		if velocity != Vector2.ZERO:
			$PivotPoint.rotation = velocity.angle()  #local with local axis
			velocity = velocity * speed
		
		velocity = move_and_slide(velocity)
		if global.is_mp():
			rpc("_update_position", position, velocity)

		if velocity != Vector2.ZERO:
			_do_walk(velocity)
		else:
			_stop_walk()

	if !is_attacking && Input.is_action_pressed("lj_attack"):
		_do_attack()

func _do_attack():
	_animate_attack()
	if global.is_mp():
		rpc("_animate_attack")
	current_attack_time = 0

func _end_attack():
	is_attacking = false
	played_chop_sound = false

puppetsync func _animate_attack():
	is_attacking = true
	play_grunt_sound()
	$AnimatedSprite.animation = "attack"

func _do_idle():
	_animate_idle()
	if global.is_mp():
		rpc("_animate_idle")

puppetsync func _animate_idle():
	$AnimatedSprite.animation = "idle"
	is_attacking = false

func _do_walk(velocity: Vector2):
	if !is_walking:
		is_walking = true
		$WalkPlayer.play()
	_animate_walk()
	$AnimatedSprite.flip_h = velocity.x > 0

func _stop_walk():
	is_walking = false
	$WalkPlayer.stop()
	_do_idle()

puppetsync func _animate_walk():
	$AnimatedSprite.animation = "walk"
	is_attacking = false

func update_target_tree():
	var chosen_tree

	if chosen_tree == null:
		for overlapped in $PivotPoint/LumberjackReticle.get_overlapping_areas():
			if overlapped.get_parent() == target_tree:
				chosen_tree = target_tree
				break
			
			if chosen_tree == null && overlapped.get_parent().is_in_group("tree"):
				chosen_tree = overlapped.get_parent()
	
	if chosen_tree != target_tree:
		if target_tree != null && is_instance_valid(target_tree):
			target_tree.un_target()
		
		target_tree = chosen_tree
		
		if target_tree != null:
			target_tree.target()

func play_chop_sound():
	played_chop_sound = true
	$ChopPlayer.stream = chop_sounds[r.randi() % chop_sounds.size()]
	$ChopPlayer.play()

func play_grunt_sound():
	$GruntPlayer.stream = grunt_sounds[r.randi() % grunt_sounds.size()]
	$GruntPlayer.play()

master func _update_position(pos: Vector2, vel: Vector2):
	position = pos
	prev_velocity = vel
