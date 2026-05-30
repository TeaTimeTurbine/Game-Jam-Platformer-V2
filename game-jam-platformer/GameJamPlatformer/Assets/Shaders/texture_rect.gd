extends TextureRect

@export var scroll_speed_x : float = 1
@export var scroll_speed_y : float = 1

func _on_ready ():
	position = Vector2(0,0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += scroll_speed_x
	position.y += scroll_speed_y
	if position.x > 640:
		position.x = -640
