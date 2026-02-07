extends Timer

signal pause_timer

signal start_timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_timer() -> void:
	self.start()


func _on_pause_timer() -> void:
	self.paused = not self.paused
