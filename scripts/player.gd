extends CharacterBody2D

@export var SPEED = 160.0
@export var JUMP_VELOCITY = -400.0

@export var DASH_SPEED = 700.0
var is_dashing = false
var dashing_dir = Vector2();


@export var nb_dash = 0;
@export var nb_coins = 0  # Maximum coins that can be held
@export var coin_regen_time = 0.4
var remaining_dash = nb_dash;
var remaining_coins = 0  # Current coins available
var coin_regen_timer = 0.0
@export var can_walljump = true;
@export var velocity_retention = 0.5;  # How much of current velocity to keep when hitting coin (0.0 = none, 1.0 = full)
var has_dash_colide = false;
var previous_velocity = Vector2.ZERO  # Track velocity for collision detection
var AfterimageScene = preload("res://trail.tscn")
var BeginCircle = preload("res://beggin_circle.tscn")
var RegchargeCircle = preload("res://recharge_circle.tscn")

var in_the_air = false

@export var freeze : bool = false

var looking = 1.0;

func _physics_process(delta: float) -> void:
	# Coin regeneration system
	if remaining_coins < nb_coins:
		coin_regen_timer += delta
		if coin_regen_timer >= coin_regen_time:
			remaining_coins += 1
			coin_regen_timer = 0.0
	else:
		coin_regen_timer = 0.0

	# Add the gravity.
	if not is_on_floor():
		in_the_air = true
		velocity += get_gravity() * delta
		wall_slide(delta)
	elif (in_the_air):
		land()

	if (Input.is_action_just_pressed("ui_accept")
		and (is_on_floor() or (is_on_wall() and can_walljump))):
		jump()

	var direction_x := Input.get_axis("ui_left", "ui_right")
	var direction_y := Input.get_axis("ui_up", "ui_down")
	if (direction_x and not is_on_wall()):
		looking = sign(direction_x)
	$AnimatedSprite2D.flip_h = looking < 0.0;
	
	# Store velocity before collision detection
	previous_velocity = velocity
	
	if (is_dashing):
		if (((is_on_floor() and dashing_dir.y > 0) or
					(is_on_ceiling() and dashing_dir.y < 0) or
					(is_on_wall() and abs(dashing_dir.x) > 0))
				and not has_dash_colide):
			has_dash_colide = true
			# Use dash speed directly since velocity gets modified by collision
			var impact_speed = DASH_SPEED
			$Camera2D.apply_shake(impact_speed)
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
			# Preserve momentum: only slow down if changing direction or at max speed
			var current_speed = abs(velocity.x)
			var target_speed = direction_x * SPEED
			
			# If moving in same direction and already faster than SPEED, don't slow down
			if sign(velocity.x) == sign(direction_x) and current_speed > SPEED:
				# Maintain high speed, just steer slightly
				velocity.x = move_toward(velocity.x, direction_x * current_speed, ACCEL * delta * 0.3)
			else:
				# Normal acceleration
				velocity.x = move_toward(velocity.x, target_speed, ACCEL * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

			#if direction_x:
			#	velocity.x = direction_x * SPEED
			#else:
			#	velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if (not freeze):
		move_and_slide()
		
		# Universal collision detection - check for any significant impacts
		check_collision_shake()

func jump():
	$"../jump_sound".play()
	velocity.y = JUMP_VELOCITY

	if is_on_wall() and not is_on_floor():
		var wall_dir = get_wall_normal().x
		# pousse à l'opposé du mur
		velocity.x = wall_dir * SPEED * 2

# Check for collisions and apply camera shake based on impact speed
func check_collision_shake():
	# Check if we hit something (velocity changed significantly)
	var velocity_change = (previous_velocity - velocity).length()
	
	# Only apply shake if not dashing (dash has its own shake)
	if velocity_change > 50.0 and not is_dashing:
		# Check what we collided with
		if is_on_wall() or is_on_floor() or is_on_ceiling():
			var impact_speed = previous_velocity.length()
			# Camera will check if speed is high enough for shake
			$Camera2D.apply_shake(impact_speed)


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

func wall_slide(delta: float):
	if is_on_wall() and velocity.y > 0:
		if not $"../wall_slide".playing:
			$"../wall_slide".play()

		looking = get_wall_normal().x
		velocity.y = 5000.0 * delta

		# Particules
		$"../wall_particules".emitting = true
		$"../wall_particules".position = position

		# Orientation selon le mur
		var wall_dir = -get_wall_normal()
		$"../wall_particules".process_material.direction = Vector3(
			wall_dir.x,
			wall_dir.y,
			0
		)
		$"../wall_particules".process_material.spread = 50;
		$"../wall_particules".position.y += 24
		$"../wall_particules".position.x += wall_dir.x * 8

	else:
		$"../wall_slide".stop()
		$"../wall_particules".emitting = false


func land():
	in_the_air = false
	$"../land".play()

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

var coin = preload("res://scenes/hit_coin.tscn")

func _process(delta: float) -> void:
	process_player_animation()
	if (is_dashing):
		spawn_trail()
	if (Input.is_action_just_pressed("slash")):
		$AnimationPlayer.play("hit")
		$"../slash".play()
	if (Input.is_action_just_pressed("spawn_coin") and remaining_coins > 0):
		var coin_e = coin.instantiate()
		remaining_coins -= 1
		# Spawn coin at player position with player velocity plus upward boost
		coin_e.position = position
		if coin_e.has_method("set_initial_velocity"):
			var initial_velocity = velocity
			initial_velocity.y -= 300.0  # Add upward velocity
			coin_e.set_initial_velocity(initial_velocity)
		get_parent().add_child(coin_e)

	process_player_scale(delta)


func _on_dash_timer_timeout() -> void:
	is_dashing = false
	velocity /= 5

func spawn_trail() -> void:
	var afterimage = AfterimageScene.instantiate()
	afterimage.position = position
	afterimage.set_texture_state($AnimatedSprite2D.scale, $AnimatedSprite2D.rotation_degrees, $AnimatedSprite2D.flip_h)
	get_parent().add_child(afterimage)


func _on_hitbox_area_entered(area: Area2D) -> void:
	if (area.name == "hit_coin_area"):
		# Send the player flying based on coin position relative to player
		var coin_position = area.global_position
		var direction = (global_position - coin_position).normalized()
		$"../coin_hit".play()

		# Impact frame freeze (Ultrakill-style)
		freeze_frame(0.1)

		# Apply knockback force with velocity retention multiplier
		var knockback_force = area.get_meta("power")
		velocity = (velocity * velocity_retention) + (direction * knockback_force)

		print(velocity)

		# Recharge dash on coin hit
		recharge_dash()


func freeze_frame(duration: float) -> void:
	# Freeze the game
	Engine.time_scale = 0.0

	# Create canvas layer for UI overlay
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # Render on top
	get_tree().root.add_child(canvas_layer)

	# Create white flash overlay
	var flash = ColorRect.new()
	flash.color = Color(1.0, 1.0, 1.0, 0.5)  # White with 50% transparency
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)  # Fill entire screen
	canvas_layer.add_child(flash)

	# Use get_tree to create a timer on the scene tree
	await get_tree().create_timer(duration, true, false, true).timeout

	# Unfreeze and remove flash
	Engine.time_scale = 1.0
	canvas_layer.queue_free()


func _on_player_unlock(mvt: Variant) -> void:
	if (mvt == "dash"):
		nb_dash += 1
		get_parent().subtract_time(30)
	if (mvt == "coin"):
		get_parent().subtract_time(50)
		remaining_coins += 1
		nb_coins += 1  # Increase max coins when unlocking
