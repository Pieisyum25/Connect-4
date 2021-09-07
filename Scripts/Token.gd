extends Sprite

onready var rising_tween = $RisingTween
onready var falling_tween = $FallingTween
#var drop_point = Vector2()
var landing_point = Vector2()

func set_colour(colour):
	frame = colour

func get_colour():
	return frame

func get_colour_value():
	match (frame):
		0:
			return Color("#ff0000")
		1:
			return Color("ff6a00")
		2:
			return Color("d9be36")
		3:
			return Color("6dd936")
		4:
			return Color("36d9be")
		5:
			return Color("0055ff")
		6:
			return Color("a040ff")
		7:
			return Color("ff40ff")
	return null;

func follow_mouse():
	set_process(true)

func _process(delta):
	var easing = 5
	position += (get_global_mouse_position() - position) / easing

func drop(drop_pos, landing_pos):
	set_process(false)
	#drop_point = drop_pos
	landing_point = landing_pos
	# tween to top, then fall:
	# tween to top:
	var pos_difference = drop_pos - position
	var duration = pos_difference.length() / 1280
	rising_tween.interpolate_property(self, "position", position, 
		position + pos_difference, duration, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	rising_tween.start()

func _on_RisingTween_tween_completed(object, key):
	var pos_difference = landing_point - position
	var duration = pos_difference.length() / 640
	falling_tween.interpolate_property(self, "position", position, 
		position + pos_difference, duration, 
		Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	falling_tween.start()

func _on_FallingTween_tween_completed(object, key):
	pass # Replace with function body.

func highlight():
	$AnimationPlayer.play("Highlight")
