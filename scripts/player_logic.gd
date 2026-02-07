extends Node2D

@export var time_remaining: float = 300.0

signal Win

signal Lose

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	time_remaining -= delta
	
	time_remaining = max(0, time_remaining)
	
	# Update display
	var min = int(time_remaining / 60.0)
	var sec = int(time_remaining) % 60
	$HUD/CanvasLayer/Time.text = "%02d : %02d" % [min, sec]


func add_time(seconds: float) -> void:
	time_remaining += seconds


func subtract_time(seconds: float) -> void:
	time_remaining -= seconds
	time_remaining = max(0, time_remaining)


func set_time(seconds: float) -> void:
	time_remaining = max(0, seconds)

func hit(damage: float) -> void:
	subtract_time(damage)


func _on_timer_timeout() -> void:
	Lose.emit()
