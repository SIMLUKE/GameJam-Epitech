extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Player.hide()
	$Player/CharacterBody2D.freeze = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_win() -> void:
	$Player.hide()
	$Player/CharacterBody2D.freeze = true
	$level2.queue_free()
	load("res://scenes/win.tscn")


func _on_player_lose() -> void:
	$Player.hide()
	$Player/CharacterBody2D.freeze = true
	$level2.queue_free()
	load("res://scenes/lost.tscn")

func _on_menu_start_game() -> void:
	$Player.show()
	$Player/CharacterBody2D.freeze = false
	$Menu.queue_free()
	add_child(load("res://scenes/level2.tscn").instantiate())
