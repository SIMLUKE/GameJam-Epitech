extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate = Color(0, 1, 0.2, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var add = 0.1 * delta
	scale += Vector2(add, add);
	self_modulate.a -= delta * 4


func _on_timer_timeout() -> void:
	queue_free()
