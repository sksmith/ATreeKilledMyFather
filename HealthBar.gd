extends Node

export var max_health = 100.0
export var bar_fall_speed = 10.0

var current_health = max_health

var bar_health = max_health
const MAX_HEALTH_SCALE = 62.969
const MIN_HEALTH_SCALE = 0.188

func _process(delta):
	if bar_health > current_health:
		bar_health -= bar_fall_speed * delta
	
	var bar_percent = bar_health / max_health
	var goop_y_scale = (MAX_HEALTH_SCALE - MIN_HEALTH_SCALE) * bar_percent
	
	var old_height = $Goop.transform.get_scale().y * $Goop.texture.get_size().y
	var new_height = goop_y_scale * $Goop.texture.get_size().y
	
	$Goop.scale = Vector2(1, goop_y_scale)
	var height_reduction = old_height - new_height
	$Goop.position = Vector2($Goop.position.x, $Goop.position.y + (height_reduction / 2))
	$GoopTop.position = Vector2($GoopTop.position.x, $GoopTop.position.y + height_reduction)
	
func hit(dmg: int):
	current_health -= dmg
	if current_health < 0:
		current_health = 0

func _on_Button_pressed():
	hit(5)
