extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	var menu = load("res://scenes/menu.tscn").instantiate()
	get_parent().add_child(menu)
	menu.start_game.connect(get_parent()._on_menu_start_game)
	queue_free()
