extends Area2D

const LEVEL_3_SCENE = preload("res://scenes/level3.tscn")
const MAIN_SCENE = preload("res://scenes/main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	body.position = Vector2(0, 0)
	get_tree().root.get_node("main").emit_signal("change_scene", LEVEL_3_SCENE.instantiate())
