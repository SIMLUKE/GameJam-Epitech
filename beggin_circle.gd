extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.modulate = Color(0, 1, 0.2, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var add = 0.1 * delta
	$Sprite2D.scale += Vector2(add, add);
	$Sprite2D.self_modulate.a -= delta * 4

func init_scale(x: float, y: float, looking: float):
	if (y == 0):
		$Sprite2D.scale = Vector2(0, 0.01)
	elif (x == 0):
		$Sprite2D.scale = Vector2(0.01, 0)
	else:
		$Sprite2D.scale = Vector2(0, 0.01)
		$Sprite2D.rotation_degrees = looking * 20
		


func _on_timer_timeout() -> void:
	queue_free()
