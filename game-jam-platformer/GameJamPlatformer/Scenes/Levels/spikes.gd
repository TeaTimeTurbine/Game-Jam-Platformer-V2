extends Area2D


signal player_damaged



func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.alive:
		emit_signal("player_damaged", body)
