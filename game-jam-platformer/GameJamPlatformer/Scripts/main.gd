extends Node2D


var level: int = 1
var score: int = 0
var current_level_root : Node = null

@onready var fade: ColorRect = $HUD/Fade
@onready var score_label: Label = $HUD/ScorePanel/ScoreLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setup the level
	fade.modulate.a = 1.0
	current_level_root = get_node("LevelRoot")
	await _load_level(level  , true , false)

# --------------------
# Level Management
# --------------------

func _load_level (level_number : int , first_load : bool , reset_score : bool) -> void:
	# Fade out
	if not first_load:
		await _fade(1.0)
	
	if reset_score == true:
		score = 0
		score_label.text = "SCORE: %s" % score
	
	if current_level_root:
		current_level_root.queue_free()
		
		# Change Level
		var level_path = "res://GameJamPlatformer/Scenes/Levels/level%s.tscn" % level_number
		current_level_root = load(level_path).instantiate()
		add_child(current_level_root)
		current_level_root.name = "LevelRoot"
		_setup_level(current_level_root)
		
		# Fade in
		await _fade(0.0)

func _setup_level(level_root : Node) -> void:
	# Connect Exit
	var exit = level_root.get_node_or_null("Exit")
	if exit:
		exit.body_entered.connect(_on_exit_body_entered)
	# Connect Enemies
	var enemies = level_root.get_node_or_null("Enemies")
	if enemies:
		for enemy in enemies.get_children():
			enemy.player_damaged.connect(_on_player_damaged)
	# Connect Traps
	var tramps = level_root.get_node_or_null("Trampolines")
	if tramps:
		for tramp in tramps.get_children():
			tramp.trampoline.connect(_bounce)
	
	# Connect Collectibles
	var collectibles = level_root.get_node_or_null("Collectibles")
	if collectibles:
		for collectible in collectibles.get_children():
			collectible.collected.connect(increase_score)
	# Connect Spikes
	var spikes = level_root.get_node_or_null("Spikes")
	if spikes:
		for spike in spikes.get_children():
			spike.player_damaged.connect(_on_player_damaged)
	# Connect Ice Blocks
	var ice_blocks = level_root.get_node_or_null("IceBlocks")
	if ice_blocks:
		for block in ice_blocks.get_children():
			block.slippery_ground.connect(_on_ice)
			block.solid_ground.connect(_off_ice)
		
	# Connect Gravity Wells
	var gravity_wells = level_root.get_node_or_null("GravityWells")
	if gravity_wells:
		for well in gravity_wells.get_children():
			well.distort_gravity.connect(_change_gravity)
			well.normal_gravity.connect(_return_gravity)

# ------------------
# SIGNAL HANDLERS
# ------------------

func _change_gravity(body : Node2D, grav_strength : float):
	body.velocity.y *= grav_strength
	
func _return_gravity(body : Node2D, grav_strength : float):
	body.velocity.y *= 1/grav_strength

func _on_exit_body_entered (body: Node2D) -> void:
	if body.name == "Player":
		level += 1
		body.can_move = false
		await _load_level(level , false , false)

func _on_player_damaged (body):
	body.die()
	await _load_level(level , false , true)

func _on_ice(body : Node2D) -> void:
	body.deceleration *= 0.1

func _off_ice(body : Node2D) -> void:
	body.deceleration *= 10
# ------------------
# SCORE
# ------------------

func increase_score () -> void:
	score += 1
	score_label.text = "SCORE: %s" % score

# ------------------
# FADE
# ------------------

func _fade (to_alpha : float) -> void:
	var tween := create_tween()
	tween.tween_property(fade , "modulate:a" , to_alpha , 1.5)
	await tween.finished

# ------------------
# BOUNCE
# ------------------
func _bounce (body : CharacterBody2D):
	if body.name == "Player":
		body.velocity.y -= 1500
