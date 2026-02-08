extends Area2D

@export var next_level = "res://scenes/level3.tscn"

const MAIN_SCENE = preload("res://scenes/main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	body.position = Vector2(0, 0)
	# Load the scene at runtime so it uses the exported variable value
	var next_scene = load(next_level)
	get_tree().root.get_node("main").emit_signal("change_scene", $"../", next_scene.instantiate())
