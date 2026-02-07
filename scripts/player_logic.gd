extends Node2D

@export var time_remaining_default: float = 300.0
var time_remaining: float = time_remaining_default

signal win

signal lose

signal unlock(mvt)

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
	
func reset() -> void:
	$CharacterBody2D.nb_coins = 0
	$CharacterBody2D.nb_dash = 0
	$CharacterBody2D.position = Vector2.ZERO
	time_remaining = time_remaining_default
	alive = true
