extends StaticBody2D

signal tree_grown(tree)
signal tree_died(tree)

export var hit_points = 5
var phase = 1
const MAX_PHASE = 3

func _ready():
	$TreeSprite.animation = "phase1"
	get_node("TargetArea/Phase1").disabled = false
	get_node("TargetArea/Phase2").disabled = true
	get_node("TargetArea/Phase3").disabled = true

func target():
	$TreeSprite.animation = "phase" + str(phase) + "_target"

func un_target():
	var current_anim = "phase" + str(phase)
	$TreeSprite.animation = current_anim
	$TreeSprite.frame = $TreeSprite.frames.get_frame_count(current_anim) - 1

func hit(damage: int):
	hit_points -= damage
	if hit_points <= 0:
		die()
		
func die():
	emit_signal("tree_died", self)
	queue_free()

func _on_LevelTimer_timeout():
	phase += 1
	
	if phase == 1:
		$TreeSprite.animation = "phase1"
		get_node("TargetArea/Phase1").disabled = false
		get_node("TargetArea/Phase2").disabled = true
		get_node("TargetArea/Phase3").disabled = true
	elif phase == 2:
		$TreeSprite.animation = "phase2"
		get_node("TargetArea/Phase1").disabled = true
		get_node("TargetArea/Phase2").disabled = false
		get_node("TargetArea/Phase3").disabled = true
	else:
		$TreeSprite.animation = "phase3"
		get_node("TargetArea/Phase1").disabled = true
		get_node("TargetArea/Phase2").disabled = true
		get_node("TargetArea/Phase3").disabled = false

	if phase >= MAX_PHASE:
		emit_signal("tree_grown", self)
		$LevelTimer.stop()
