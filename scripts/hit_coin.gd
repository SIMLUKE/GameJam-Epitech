extends Node2D

@export var velocity: Vector2 = Vector2.ZERO
@export var gravity: float = 300.0  # Gravity acceleration (reduced for slower fall)
@export var damping: float = 0.93  # Velocity damping

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Apply gravity
	velocity.y += gravity * delta
	
	# Apply damping (air resistance)
	velocity *= damping
	
	# Move the coin
	position += velocity * delta


func set_initial_velocity(initial_velocity: Vector2) -> void:
	velocity = initial_velocity


func _on_timer_timeout() -> void:
	queue_free()
