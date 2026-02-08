extends Camera2D

@export var randomStrength: float = 5.0
@export var shakeFade: float = 5.0
@export var follow_speed: float = 8.0  # Higher = faster follow (range: 1-30 recommended)
@export var speed_shake_multiplier: float = 0.01  # How much speed affects shake intensity
@export var min_shake_speed: float = 300.0  # Minimum speed required to trigger shake (dash speed is 700)

var rng = RandomNumberGenerator.new()

var shake_strength: float = 0.0

func _ready():
	position_smoothing_enabled = true
	position_smoothing_speed = follow_speed

func apply_shake(impact_speed: float = 0.0):
	if impact_speed > 0.0:
		if impact_speed >= min_shake_speed:
			$"../../impact".play()
			shake_strength = min(impact_speed * speed_shake_multiplier, randomStrength * 3.0)
	else:
		$"../../impact".play()
		shake_strength = randomStrength

func _process(delta):
	if shake_strength > 0.0:
		shake_strength = lerp(shake_strength, 0.0, shakeFade * delta)
		
		offset = randomOffset()

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
