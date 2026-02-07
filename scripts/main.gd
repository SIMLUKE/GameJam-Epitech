extends Node

# Preload scenes to avoid loading them multiple times
const WIN_SCENE = preload("res://scenes/win.tscn")
const LOST_SCENE = preload("res://scenes/lost.tscn")
const LEVEL2_SCENE = preload("res://scenes/level2.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Player.hide()
	$Player/CharacterBody2D.position = Vector2.ZERO
	$Player/CharacterBody2D.freeze = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_win() -> void:
	$Player.hide()
	$Player/CharacterBody2D.freeze = true
	$Player/CharacterBody2D.position = Vector2.ZERO
	$level2.queue_free()
	var win_scene = WIN_SCENE.instantiate()
	add_child(win_scene)
	# Connect signals if the win scene has any (e.g., restart button)


func _on_player_lose() -> void:
	print("lose")
	$Player.hide()
	$Player/CharacterBody2D.freeze = true
	$Player/CharacterBody2D.position = Vector2.ZERO
	$level2.queue_free()
	var lost_scene = LOST_SCENE.instantiate()
	add_child(lost_scene)

func _on_menu_start_game() -> void:
	$Player.show()
	$Player/CharacterBody2D.freeze = false
	$Player.reset()
	$Menu.queue_free()
	add_child(LEVEL2_SCENE.instantiate())


func _on_death_plane_body_entered(body: Node2D) -> void:
	var parent = body.get_parent()
	if (parent && parent.name == "Player"):
		parent.subtract_time(10000000000)
	elif(parent):
		parent.queue_free()
	else:
		body.queue_free()
