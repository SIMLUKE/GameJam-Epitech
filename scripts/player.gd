extends CharacterBody2D


const SPEED = 220.0
const JUMP_VELOCITY = -400.0

const DASH_SPEED = 700.0
var is_dashing = false
var dashing_dir = Vector2();

@export var nb_dash = 1;
var remaining_dash = nb_dash;
var AfterimageScene = preload("res://trail.tscn")

var looking = 1.0;

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var direction_x := Input.get_axis("ui_left", "ui_right")
	var direction_y := Input.get_axis("ui_up", "ui_down")
	if (direction_x):
		looking = sign(direction_x)
	$AnimatedSprite2D.flip_h = looking < 0.0;
	if (is_dashing):
		velocity.x = dashing_dir.x * DASH_SPEED
		velocity.y = dashing_dir.y * DASH_SPEED
	else:
		if (Input.is_action_just_pressed("dash") and remaining_dash > 0):
			remaining_dash -= 1;
			var dash_input = Vector2(direction_x, direction_y)
			if dash_input == Vector2.ZERO:
				dash_input.x = looking
			dashing_dir = dash_input.normalized()
			is_dashing = true
			$dash_timer.start()
		else:
			if is_on_floor():
				remaining_dash = nb_dash
			if direction_x:
				velocity.x = direction_x * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()

const dashing_scale = Vector2(1.3, 0.7)
const default_scale = Vector2(1.0, 1.0)

func set_player_scale_x(new: float, min_val: float, max_val: float):
	$AnimatedSprite2D.scale.x = clamp(new, min_val, max_val)

func set_player_scale_y(new: float, min_val: float, max_val: float):
	$AnimatedSprite2D.scale.y = clamp(new, min_val, max_val)

func process_player_scale(delta: float):
	var speed_dash := 0.4 * delta * 15
	var speed_reset := 0.4 * delta * 10

	if is_dashing:
		var ax = abs(dashing_dir.x)
		var ay = abs(dashing_dir.y)

		if ax > ay:
			set_player_scale_x(
				$AnimatedSprite2D.scale.x + speed_dash,
				default_scale.x,
				dashing_scale.x
			)
			set_player_scale_y(
				$AnimatedSprite2D.scale.y - speed_dash,
				dashing_scale.y,
				default_scale.y
			)

		elif ay > ax:
			set_player_scale_x(
				$AnimatedSprite2D.scale.x - speed_dash,
				dashing_scale.y,
				default_scale.x
			)
			set_player_scale_y(
				$AnimatedSprite2D.scale.y + speed_dash,
				default_scale.y,
				dashing_scale.x
			)

		else:
			pass

	else:
		# Retour smooth à la normale
		set_player_scale_x(
			$AnimatedSprite2D.scale.x - speed_reset,
			default_scale.x,
			dashing_scale.x
		)
		set_player_scale_y(
			$AnimatedSprite2D.scale.y + speed_reset,
			dashing_scale.y,
			default_scale.y
		)


func process_player_animation() -> void:
	if (velocity.x == 0 and velocity.y == 0):
		$AnimatedSprite2D.play("default")
	else:
		$AnimatedSprite2D.play("run")
	
		

func _process(delta: float) -> void:
	process_player_animation()
	if (is_dashing):
		spawn_trail()

	process_player_scale(delta)


func _on_dash_timer_timeout() -> void:
	is_dashing = false
	velocity /= 5

func spawn_trail() -> void:
	var afterimage = AfterimageScene.instantiate()
	afterimage.global_position = global_position
	afterimage.set_texture_state($AnimatedSprite2D.scale, $AnimatedSprite2D.flip_h)
	get_parent().add_child(afterimage)
	
