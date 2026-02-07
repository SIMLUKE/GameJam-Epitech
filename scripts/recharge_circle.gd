extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.scale = Vector2(0.03, 0.03)
	$Sprite2D.modulate = Color(0, 1, 0.2, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var add = 0.1 * delta
	$Sprite2D.scale -= Vector2(add, add);
	$Sprite2D.modulate.a += 8 * delta


func _on_timer_timeout() -> void:
	queue_free()
