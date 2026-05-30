extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $SpringAnim
@onready var player: CharacterBody2D = $"../../Player"
@onready var trampoline_sound: AudioStreamPlayer2D = $TrampolineSound
@onready var timer: Timer = $Timer

signal trampoline

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		trampoline_sound.play()
		emit_signal("trampoline",body)
		animated_sprite_2d.animation = "Jump"
		timer.start()

func _on_timer_timeout() -> void:
	animated_sprite_2d.animation = "Idle"
	
