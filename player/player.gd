extends KinematicBody2D

enum AnimState {ANIM_IDLE, ANIM_WALK, ANIM_CHARGE, ANIM_HOLD, ANIM_LAUNCH, ANIM_RISING, ANIM_FALLING, ANIM_GET_BANANA, ANIM_CELEBRATION, ANIM_PRETWERK, ANIM_TWERK}

const GRAVITY = 800
const MAX_JUMP_TIME = 1.0
const JUMP_TIME_START = 0.1
const JUMP_SPEED = 315
const BANANA_JUMP_SPEED = 480
const MAX_X_SPEED = 64
const SLOPE_SPEED = 250
const BLACK_HOLE_GRAVITY = 200
const TWERK_TIME = 15.0

var velocity = Vector2.ZERO
var current_jump_time = JUMP_TIME_START
var last_x_velocity = 0
var floatiness = 1.0
var has_jumped = false
var is_charging_jump = false
var animation_state = AnimState.ANIM_IDLE
var current_banana = null
var banana_timer = null
var black_holes = []
var is_floatiness_enabled = false
var did_finish_game = false
var jump_fart_node = preload("res://particles/jump_fart.tscn")
var last_facing_direction = 1
var force_redraw = false
var twerk_timer = 0

func _ready():
	$AnimatedSprite.connect("animation_finished", self, "on_animation_finish")

# ===================== MOVEMENT


func _physics_process(delta):
	if did_finish_game:
		return
	
	# gravity
	velocity.y += GRAVITY * delta * floatiness
	
	# jumping
	if is_on_floor():
		if has_jumped:
			$LandingAudioPlayer.play()
			has_jumped = false
			velocity.x = 0
			last_x_velocity = 0
			switch_animation_state(AnimState.ANIM_IDLE)
		
		# horizontal
		var x_direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		
		if not is_charging_jump:
			if x_direction != 0:
				twerk_timer = 0
				switch_animation_state(AnimState.ANIM_WALK)
				velocity.x += x_direction * delta * 512
				velocity.x = clamp(velocity.x, -MAX_X_SPEED, MAX_X_SPEED)
			else:
				twerk_timer += delta
				if twerk_timer >= TWERK_TIME:
					switch_animation_state(AnimState.ANIM_PRETWERK)
				else:
					switch_animation_state(AnimState.ANIM_IDLE)
				velocity.x = lerp(velocity.x, 0, 0.5)
		
		if x_direction != 0:
			last_facing_direction = x_direction
			$AnimatedSprite.scale.x = x_direction
		
		# vertical
		if Input.is_action_just_pressed("ui_select"):
			switch_animation_state(AnimState.ANIM_CHARGE)
		if Input.is_action_pressed("ui_select"):
			is_charging_jump = true
			velocity.x = 0
			current_jump_time += delta
			current_jump_time = clamp(current_jump_time, JUMP_TIME_START, MAX_JUMP_TIME)
		if Input.is_action_just_released("ui_select"):
			$JumpAudioPlayer.play()
			
			var jump_fart = jump_fart_node.instance()
			jump_fart.is_left = true if last_facing_direction == 1 else false
			jump_fart.position = self.position
			get_tree().get_root().get_node("LevelNode").add_child(jump_fart)
			
			var final_jump_speed = get_jump_speed() * (current_jump_time / MAX_JUMP_TIME)
			velocity.y = -final_jump_speed
			velocity.x = (x_direction * final_jump_speed) / 2
			last_x_velocity = velocity.x
			current_jump_time = JUMP_TIME_START
			has_jumped = true
			is_charging_jump = false
			switch_animation_state(AnimState.ANIM_LAUNCH)
	else:
		if velocity.x != 0:
			last_x_velocity = velocity.x
		if is_on_wall():
			$BonkAudioPlayer.play()
			velocity.x = -last_x_velocity * 0.6
		if is_on_ceiling():
			$BonkAudioPlayer.play()
		
		if velocity.y >= 0:
			switch_animation_state(AnimState.ANIM_FALLING)
		if has_jumped == false:
			has_jumped = true
	
	handle_slopes()
	
	velocity = move_and_slide(velocity, Vector2.UP)

func handle_slopes():
	var slide_count = get_slide_count()
	if slide_count > 0:
		for i in slide_count:
			var slide_collision = get_slide_collision(i)
			var collision_normal = slide_collision.normal
			var angle = rad2deg(acos(collision_normal.dot(Vector2.UP)))
			if fmod(abs(angle), 90) != 0.0:
				switch_animation_state(AnimState.ANIM_FALLING)
				var slope_is_left = false if collision_normal.x >= 0 else true
				var slope_rotate_degrees = -90 if slope_is_left else 90
				var slope_rotate_radians = deg2rad(slope_rotate_degrees)
				var slope_vector = collision_normal.rotated(slope_rotate_radians)
				velocity = slope_vector.normalized() * SLOPE_SPEED

func get_jump_speed():
	if current_banana != null:
		banana_timer = Timer.new()
		banana_timer.wait_time = 1.0
		banana_timer.autostart = false
		banana_timer.one_shot = true
		add_child(banana_timer)
		banana_timer.connect("timeout", self, "on_finished_banana_timer")
		banana_timer.start()
		
		return BANANA_JUMP_SPEED
	else:
		return JUMP_SPEED
		
func handle_black_hole(delta):
	if !black_holes.empty():
		for black_hole in black_holes:
			var radius = black_hole.get_size()
			var black_hole_position = black_hole.position
			var monkey_position = position
			var distance = Vector2(
				black_hole.position.x - position.x,
				black_hole.position.y - position.y
			)
			var strength = Vector2(
				1 - clamp((abs(distance.x) / radius.x), 0, 0.9),
				1 - clamp((abs(distance.y) / radius.y), 0, 0.9)
			)
			var direction = distance.sign()
			velocity.x += direction.x * (BLACK_HOLE_GRAVITY) * delta
			velocity.y += direction.y * (BLACK_HOLE_GRAVITY) * delta

func on_finished_banana_timer():
	if current_banana != null:
		current_banana.enable_banana()
		current_banana = null
		banana_timer = null

# ===================== ANIMATION

func switch_animation_state(updated_state):
	if animation_state != updated_state || force_redraw:
		animation_state = updated_state
		force_redraw = false
		
		if animation_state == AnimState.ANIM_IDLE:
			if is_floatiness_enabled:
				$AnimatedSprite.play("space_idle")
			else:
				$AnimatedSprite.play("idle")
		elif animation_state == AnimState.ANIM_WALK:
			if is_floatiness_enabled:
				$AnimatedSprite.play("space_walk")
			else:
				$AnimatedSprite.play("walk")
		elif animation_state == AnimState.ANIM_CHARGE:
			if is_floatiness_enabled:
				$AnimatedSprite.play("space_charge")
			else:
				$AnimatedSprite.play("charge")
		elif animation_state == AnimState.ANIM_HOLD:
			if is_floatiness_enabled:
				$AnimatedSprite.play("space_hold")
			else:
				$AnimatedSprite.play("hold")
		elif animation_state == AnimState.ANIM_LAUNCH:
			if is_floatiness_enabled:
				$AnimatedSprite.play("space_launch")
			else:
				$AnimatedSprite.play("launch")
		elif animation_state == AnimState.ANIM_RISING:
			if is_floatiness_enabled:
				$AnimatedSprite.play("space_rising")
			else:
				$AnimatedSprite.play("rising")
		elif animation_state == AnimState.ANIM_FALLING:
			if is_floatiness_enabled:
				$AnimatedSprite.play("space_falling")
			else:
				$AnimatedSprite.play("falling")
		elif animation_state == AnimState.ANIM_GET_BANANA:
			$AnimatedSprite.play("get_banana")
		elif animation_state == AnimState.ANIM_CELEBRATION:
			$AnimatedSprite.play("celebration")
		elif animation_state == AnimState.ANIM_PRETWERK:
			$AnimatedSprite.play("prewtwerk")
		elif animation_state == AnimState.ANIM_TWERK:
			$AnimatedSprite.play("twerk")
			
func on_animation_finish():
	if animation_state == AnimState.ANIM_CHARGE:
		switch_animation_state(AnimState.ANIM_HOLD)
	elif animation_state == AnimState.ANIM_LAUNCH:
		switch_animation_state(AnimState.ANIM_RISING)
	elif animation_state == AnimState.ANIM_GET_BANANA:
		switch_animation_state(AnimState.ANIM_CELEBRATION)
	elif animation_state == AnimState.ANIM_PRETWERK:
		switch_animation_state(AnimState.ANIM_TWERK)


# ===================== BANANA

func did_get_banana(banana):
	if current_banana == null:
		current_banana = banana
		current_banana.disable_banana()


# ===================== GRAVITY

func toggle_floatiness():
	is_floatiness_enabled = !is_floatiness_enabled
	floatiness = 1.0 if !is_floatiness_enabled else 0.7
	force_redraw = true

	
# ===================== FINISHED GAME

func on_finished_game():
	did_finish_game = true
	$PowerupAudioPlayer.play()
	switch_animation_state(AnimState.ANIM_GET_BANANA)

# ===================== BLACK HOLE

func did_enter_black_hole(black_hole):
	black_holes.append(black_hole)

func did_exit_black_hole(black_hole):
	black_holes.erase(black_hole)
