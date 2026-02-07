extends AnimatedSprite2D

@export var rotation_speed: float = 2.0
@export var scale_speed: float = 2.0
@export var min_scale: float = 0.8
@export var max_scale: float = 1.3

var time_passed: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_passed += delta
	
	# Rotate the star
	rotation += rotation_speed * delta
	
	# Oscillate scale between min and max
	var scale_factor = min_scale + (max_scale - min_scale) * (sin(time_passed * scale_speed) * 0.5 + 0.5)
	scale = Vector2(scale_factor, scale_factor)
