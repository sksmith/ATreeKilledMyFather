extends Area2D

signal hit

export var speed = 400 # How fast the player will move (pixels/sec).
export var attack_duration_ms = 0.5
var screen_size # Size of the game window.
var is_attacking = false
var current_attack_time = 0

func start(pos):
	position = pos
	show()
	$AnimatedSprite.play()
	$CollisionShape2D.disabled = false

func _ready():
	screen_size = get_viewport_rect().size
	hide()

func _process(delta):
	if !is_attacking && Input.is_action_pressed("attack"):
		is_attacking = true
		current_attack_time = 0
		$AnimatedSprite.animation = "attack"
	
	if is_attacking:
		current_attack_time += delta
		
		if current_attack_time >= attack_duration_ms:
			is_attacking = false
			$AnimatedSprite.animation = "idle"
	else:
		var velocity = Input.get_vector("lj_aim_left", "lj_aim_right", "lj_aim_up", "lj_aim_down")

		if velocity.length() > 0:
			velocity = velocity * speed
		
		position += velocity * delta
		position.x = clamp(position.x, 0, screen_size.x)
		position.y = clamp(position.y, 0, screen_size.y)

		if velocity.x != 0:
			$AnimatedSprite.animation = "walk"
			$AnimatedSprite.flip_h = velocity.x > 0
		else:
			$AnimatedSprite.animation = "idle"
			
		$PivotPoint.rotation = velocity.angle()  #local with local axis

func _on_Player_body_entered(body):
	hide() # Player disappears after being hit.
	emit_signal("hit")
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
