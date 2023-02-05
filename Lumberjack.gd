extends KinematicBody2D

export var speed = 200 # How fast the player will move (pixels/sec).
export var attack_duration_ms = 0.5
export var chop_sounds: Array
export var grunt_sounds: Array
var r = RandomNumberGenerator.new()
var screen_size # Size of the game window.
var is_attacking = false
var current_attack_time = 0
var target_tree
var is_walking = false
var played_chop_sound = false

func start(pos):
	position = pos
	show()
	$AnimatedSprite.play()

func _ready():
	screen_size = get_viewport_rect().size
	hide()

func _process(delta):
	update_target_tree()

func _physics_process(delta):
	if !is_attacking && Input.is_action_pressed("attack"):
		is_attacking = true
		play_grunt_sound()
		current_attack_time = 0
		$AnimatedSprite.animation = "attack"
	
	if is_attacking:
		current_attack_time += delta
		
		if $AnimatedSprite.frame == 1 && target_tree != null:
			play_chop_sound()
		
		if current_attack_time >= attack_duration_ms:
			is_attacking = false
			played_chop_sound = false
			$AnimatedSprite.animation = "idle"
			
			if target_tree != null:
				target_tree.hit(2)
			
				if target_tree.is_dead():
					print("tree fall sound")
					$TreeFall.play()
	else:
		var velocity = Input.get_vector("lj_aim_left", "lj_aim_right", "lj_aim_up", "lj_aim_down")

		if velocity.length() > 0:
			$PivotPoint.rotation = velocity.angle()  #local with local axis
			velocity = velocity * speed
		
		velocity = move_and_slide(velocity)

		if velocity.x != 0:
			if !is_walking:
				is_walking = true
				$WalkPlayer.play()
			$AnimatedSprite.animation = "walk"
			$AnimatedSprite.flip_h = velocity.x > 0
		else:
			if is_walking:
				is_walking = false
				$WalkPlayer.stop()
				
			$AnimatedSprite.animation = "idle"

func update_target_tree():
	var chosen_tree
	for overlapped in $PivotPoint/LumberjackReticle.get_overlapping_areas():
		if overlapped.get_parent() == target_tree:
			chosen_tree = target_tree
			break
	
	if chosen_tree == null:
		for overlapped in $PivotPoint/LumberjackReticle.get_overlapping_areas():
			if overlapped.get_parent().is_in_group("tree"):
				chosen_tree = overlapped.get_parent()
				break
	
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
