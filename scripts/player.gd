extends CharacterBody2D


const SPEED = 220.0
const JUMP_VELOCITY = -400.0

const DASH_SPEED = 700.0
var is_dashing = false
var dashing_dir = Vector2();

@export var nb_dash = 4;
var remaining_dash = nb_dash;
@export var can_walljump = true;
var has_dash_colide = false;
var AfterimageScene = preload("res://trail.tscn")
var BeginCircle = preload("res://beggin_circle.tscn")
var RegchargeCircle = preload("res://recharge_circle.tscn")


@export var freeze : bool = false

var looking = 1.0;

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if (is_on_wall()):
			looking = get_wall_normal().x
			velocity.y = 5000.0 * delta

	if (Input.is_action_just_pressed("ui_accept")
		and (is_on_floor() or (is_on_wall() and can_walljump))):
		jump()

	var direction_x := Input.get_axis("ui_left", "ui_right")
	var direction_y := Input.get_axis("ui_up", "ui_down")
	if (direction_x and not is_on_wall()):
		looking = sign(direction_x)
	$AnimatedSprite2D.flip_h = looking < 0.0;
	if (is_dashing):
		if (((is_on_floor() and dashing_dir.y > 0) or
					(is_on_ceiling() and dashing_dir.y < 0) or
					(is_on_wall() and abs(dashing_dir.x) > 0))
				and not has_dash_colide):
			has_dash_colide = true
			$Camera2D.apply_shake()
		velocity.x = dashing_dir.x * DASH_SPEED
		velocity.y = dashing_dir.y * DASH_SPEED
	else:
		has_dash_colide = false
		if (Input.is_action_just_pressed("dash") and remaining_dash > 0):
			dash(direction_x, direction_y)
		else:
			if is_on_floor():
				recharge_dash()
		const ACCEL = 2000.0
		var FRICTION = 0.0
		if (is_on_floor()):
			FRICTION = 1800.0
		else:
			FRICTION = 300.0

		if direction_x != 0:
			velocity.x = move_toward(velocity.x, direction_x * SPEED, ACCEL * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

			#if direction_x:
			#	velocity.x = direction_x * SPEED
			#else:
			#	velocity.x = move_toward(velocity.x, 0, SPEED)
	if (not freeze):
		move_and_slide()

func jump():
	$"../jump_sound".play()
	velocity.y = JUMP_VELOCITY

	if is_on_wall() and not is_on_floor():
		var wall_dir = get_wall_normal().x
		# pousse à l'opposé du mur
		velocity.x = wall_dir * SPEED * 2


func dash(x, y):
	$"../dash_sound".play()
	remaining_dash -= 1;
	var dash_input = Vector2(x, y)
	if dash_input == Vector2.ZERO:
		dash_input.x = looking
	dashing_dir = dash_input.normalized()
	is_dashing = true
	$dash_timer.start()
	var begin_circle = BeginCircle.instantiate()
	begin_circle.position = position
	begin_circle.init_scale(x, y, looking)
	get_parent().add_child(begin_circle)

func recharge_dash():
	if (remaining_dash != nb_dash):
		remaining_dash = nb_dash
		var recharge_circle = RegchargeCircle.instantiate()
		recharge_circle.position = Vector2.ZERO
		add_child(recharge_circle)


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

		else:
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
			if (abs(ay - ax) < 0.01):
				$AnimatedSprite2D.rotation_degrees = looking * 20
	else:
		# intensité basée sur la vitesse verticale
		var max_fall_speed := 500.0
		var t = clamp(abs(velocity.y) / max_fall_speed, 0.0, 1.0)

		# scale dynamique
		var target_scale_y = lerp(1.0, 1.4, t)
		var target_scale_x = lerp(1.0, 0.6, t)

		# application smooth
		$AnimatedSprite2D.scale.x = lerp(
			$AnimatedSprite2D.scale.x,
			target_scale_x,
			delta * 20
		)
		$AnimatedSprite2D.scale.y = lerp(
			$AnimatedSprite2D.scale.y,
			target_scale_y,
			delta * 20
		)

		$AnimatedSprite2D.rotation_degrees = 0


func process_player_animation() -> void:
	if ($AnimatedSprite2D.animation != "default" or $AnimatedSprite2D.animation != "run"):
		return
	if (velocity.x == 0 and velocity.y == 0):
		$AnimatedSprite2D.play("default")
	else:
		$AnimatedSprite2D.play("run")



func _process(delta: float) -> void:
	process_player_animation()
	if (is_dashing):
		spawn_trail()
	if (Input.is_action_just_pressed("slash")):
		$AnimationPlayer.play("hit")

	process_player_scale(delta)


func _on_dash_timer_timeout() -> void:
	is_dashing = false
	velocity /= 5

func spawn_trail() -> void:
	var afterimage = AfterimageScene.instantiate()
	afterimage.position = position
	afterimage.set_texture_state($AnimatedSprite2D.scale, $AnimatedSprite2D.rotation_degrees, $AnimatedSprite2D.flip_h)
	get_parent().add_child(afterimage)
