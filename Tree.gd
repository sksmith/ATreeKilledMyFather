extends StaticBody2D

signal tree_grown(tree)
signal tree_died(tree)

export var hit_points = 5
export var tree_growth_sounds: Array
var phase = 1
const MAX_PHASE = 3

var play_growth_sound = true

func _ready():
	$TreeSprite.animation = "phase1"
	get_node("TargetArea/Phase1").disabled = false
	get_node("TargetArea/Phase2").disabled = true
	get_node("TargetArea/Phase3").disabled = true

func _process(_delta):
	pass
#	if $TreeSprite.frame == 2:
#		$TreeGrowthSound.play()

func target():
	$TreeSprite.animation = "phase" + str(phase) + "_target"

func un_target():
	var current_anim = "phase" + str(phase)
	$TreeSprite.animation = current_anim
	$TreeSprite.frame = $TreeSprite.frames.get_frame_count(current_anim) - 1

func hit(damage: int):
	hit_points -= damage
	if is_dead():
		die()
		
func die():
	emit_signal("tree_died", self)
	queue_free()

func is_dead():
	return hit_points <= 0
	
func set_phase(new_phase: int):
	phase = new_phase
	play_growth_sound = false
	grow()
	$TreeSprite.set_frame(4)
	play_growth_sound = true

func _on_LevelTimer_timeout():
	phase += 1
	grow()
	
func grow():
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
		var growth_sound = tree_growth_sounds[randi() % tree_growth_sounds.size()]
		$LevelTimer.stop()
		if play_growth_sound:
			$TreeGrowthSound.stream = growth_sound
			yield(get_tree().create_timer(0.8), "timeout")
			$TreeGrowthSound.play()
		
