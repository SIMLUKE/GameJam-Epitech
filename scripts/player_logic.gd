extends Node2D

@export var time_remaining_default: float = 300.0
var time_remaining: float = time_remaining_default

var coin = preload("res://scenes/hit_coin.tscn")

signal win

signal lose

var alive = true

func _ready() -> void:
	$CharacterBody2D/AnimatedSprite2D.play("default")


func _process(delta: float) -> void:
	if (not $CharacterBody2D.freeze):
		time_remaining -= delta
	
	time_remaining = max(0, time_remaining)
	
	# Update display
	var min = int(time_remaining / 60.0)
	var sec = int(time_remaining) % 60
	$HUD/CanvasLayer/Time.text = "%02d : %02d" % [min, sec]
	
	var progress_bar = $HUD/CanvasLayer/TextureProgressBar
	if progress_bar:
		progress_bar.value = time_remaining
		progress_bar.max_value = time_remaining_default
	else:
		print("ERROR: Progress bar not found!")
	
	if (alive and time_remaining <= 0):
		alive = false
		print("dead")
		$CharacterBody2D/AnimatedSprite2D.play("dead")
	if (Input.is_action_just_pressed("spawn_coin")):
		var coin_e = coin.instantiate()
		# Spawn coin at player position with player velocity plus upward boost
		coin_e.position = $CharacterBody2D.position
		if coin_e.has_method("set_initial_velocity"):
			var initial_velocity = $CharacterBody2D.velocity
			initial_velocity.y -= 300.0  # Add upward velocity
			coin_e.set_initial_velocity(initial_velocity)
		add_child(coin_e)


func add_time(seconds: float) -> void:
	time_remaining += seconds


func subtract_time(seconds: float) -> void:
	time_remaining -= seconds
	time_remaining = max(0, time_remaining)


func set_time(seconds: float) -> void:
	time_remaining = max(0, seconds)

func hit(damage: float) -> void:
	$CharacterBody2D/AnimatedSprite2D.play("hurt")
	subtract_time(damage)


func _on_animated_sprite_2d_animation_finished() -> void:
	if ($CharacterBody2D/AnimatedSprite2D.animation == "dead"):
		lose.emit()
	$CharacterBody2D/AnimatedSprite2D.play("default")
	
