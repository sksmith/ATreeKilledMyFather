extends KinematicBody2D

export var speed = 4 # How fast the player will move (pixels/sec).
export var attack_duration_ms = 0.5
var screen_size # Size of the game window.
var is_attacking = false
var current_attack_time = 0
var target_tree

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
		current_attack_time = 0
		$AnimatedSprite.animation = "attack"
	
	if is_attacking:
		current_attack_time += delta
		
		if current_attack_time >= attack_duration_ms:
			is_attacking = false
			$AnimatedSprite.animation = "idle"
			
			if target_tree != null:
				target_tree.hit(2)
	else:
		var velocity = Input.get_vector("lj_aim_left", "lj_aim_right", "lj_aim_up", "lj_aim_down")

		if velocity.length() > 0:
			$PivotPoint.rotation = velocity.angle()  #local with local axis
			velocity = velocity * speed
		
		move_and_slide(velocity)

		if velocity.x != 0:
			$AnimatedSprite.animation = "walk"
			$AnimatedSprite.flip_h = velocity.x > 0
		else:
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


func _on_LumberjackReticle_area_entered(area):
#	var bodies = $PivotPoint/LumberjackReticle.get_overlapping_areas()
	print("lumberjack area entered")
	pass # Replace with function body.
