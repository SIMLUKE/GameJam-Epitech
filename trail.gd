extends Node2D

func _ready() -> void:
	$AnimatedSprite2D.self_modulate.g = 5
	$AnimatedSprite2D.self_modulate.b = 2

	
func set_texture_state(scale: Vector2, rotation: float, flip_h: bool):
	$AnimatedSprite2D.scale = scale
	$AnimatedSprite2D.rotation_degrees = rotation
	$AnimatedSprite2D.flip_h = flip_h


func _process(delta: float) -> void:
	$AnimatedSprite2D.self_modulate.a -= (5 * delta)


func _on_trail_death_cooldown_timeout() -> void:
	queue_free()
