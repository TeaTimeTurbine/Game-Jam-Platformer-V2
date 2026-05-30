extends StaticBody2D


signal slippery_ground
signal solid_ground



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		emit_signal("slippery_ground", body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		emit_signal("solid_ground", body)
