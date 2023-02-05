extends Area2D

signal tree_grown(tree)

export var hit_points = 5
var phase = 1
const MAX_PHASE = 3

func _ready():
	$TreeSprite.animation = "phase1"

func target():
	$TreeSprite.animation = "phase" + str(phase) + "_target"

func un_target():
	var current_anim = "phase" + str(phase)
	$TreeSprite.animation = current_anim
	$TreeSprite.frame = $TreeSprite.frames.get_frame_count(current_anim) - 1

func hit(damage: int):
	hit_points -= damage
	if hit_points <= 0:
		queue_free()

func _on_LevelTimer_timeout():
	phase += 1
	$TreeSprite.animation = "phase" + str(phase)
	
	if phase >= MAX_PHASE:
		emit_signal("tree_grown", self)
		$LevelTimer.stop()
