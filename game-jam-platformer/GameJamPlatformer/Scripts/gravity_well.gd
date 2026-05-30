extends Node2D

@onready var area_2d: Area2D = $Area2D

signal distort_gravity
signal normal_gravity
@export var grav_strength : float = 0.5


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		emit_signal("distort_gravity", body, grav_strength)



func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		emit_signal("normal_gravity" , body , grav_strength)
