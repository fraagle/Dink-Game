extends CharacterBody2D

class_name Player

signal player_dinked
signal player_dashed

@onready var death_particles: GPUParticles2D = $DeathParticles
@onready var respawn_particles: GPUParticles2D = $RespawnParticles

@export var movement_data: PlayerMovementData
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


@onready var emote_animation: AnimationPlayer = $Emote/EmoteAnimation
@onready var emote_face_happy: Sprite2D = $Emote/EmoteFaceHappy

@onready var starting_position = position

#@onready var camera_2d: Camera2D = $"../Camera2D"d
#@onready var camdera_starting_position = camera_2d.position

@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
@onready var wall_jump_timer: Timer = $WallJumpTimer
@onready var slide_timer: Timer = $SlideTimer

@onready var dash_duration_timer: Timer = $DashDurationTimer
@onready var dash_effect_timer: Timer = $DashEffectTimer

@onready var target_position: Vector2 = Vector2.ZERO
@onready var dink = false
@onready var targeted = false

@onready var dink_radius: Area2D = $DinkRadius
@onready var dink_radius_pos =  dink_radius.position.x


@onready var dash_sound: AudioStreamPlayer = $Node/DashSound


@onready var land_1: AudioStreamPlayer = $Node/Jump/Land1
@onready var land_2: AudioStreamPlayer = $Node/Jump/Land2
@onready var land_3: AudioStreamPlayer = $Node/Jump/Land3
@onready var land_4: AudioStreamPlayer = $Node/Jump/Land4
@onready var land_sounds = [land_1, land_2, land_3, land_4]

# jump
var jump_buffered = false

# double jump
var air_jump = false
var double_jump = false  # disable double jump

# wall jump
var just_left_wall = false
var just_wall_jumped = false
var was_wall_normal = Vector2.ZERO
var frames_on_wall = 0
const wall_slide_frames = 10
var last_wall_jump_axis = 0

var boost_wall_jump = false

# dash
var can_dash = true
var do_dash = false
var do_vert_dash = false
var just_dashed = false
var dash_direction : int
var last_input_axis = 0.0
var current_dash_axis: float = 0.0

#dink
var dink_direction = Vector2.ZERO
var dink_input_axis = 0

@onready var enabled_controls: bool = true

func _ready():
	#camera_2d.position_smoothing_enabled = true
	emote_face_happy.visible = false
	#pass

func _physics_process(delta: float) -> void:
	# runs for every physics tick frame of the game
	# delta how long between each frame
	
	#if enabled_controls:
	var input_axis := Input.get_axis("move_left", "move_right")
	var vert_input_axis := Input.get_axis('move_up','move_down')
	
	
	if (input_axis > 0) and (input_axis != 0):
		input_axis = 1
	if (input_axis < 0) and (input_axis != 0):
		input_axis = -1
		
	if (vert_input_axis > 0) and (vert_input_axis != 0):
		vert_input_axis = 1
	if (vert_input_axis < 0) and (vert_input_axis != 0):
		vert_input_axis = -1
	
	#print(vert_input_axis)
	
	handle_wall_slide(input_axis)
	handle_wall_jump(input_axis)
	handle_jump(delta)
	
	handle_dash(input_axis,vert_input_axis, delta)
	
	apply_gravity(delta)
	
	handle_acceleration(input_axis, delta)
	handle_air_acceleration(input_axis, delta)

	#update_animations(input_axis)
	
	handle_dink(input_axis,delta)
	#dink_radius(input_axis)
	
	
	
	
	var was_on_floor = is_on_floor()
	var was_on_wall = is_on_wall_only()
	
	
	if was_on_wall:
		was_wall_normal = get_wall_normal()
		
	move_and_slide() # already multiplies velocity by delta, not acceleration tho.
	
	# jump buffer
	if not was_on_floor and is_on_floor():
		if jump_buffered:
			jump()
			jump_buffered = false
	
	# walll-jump buffer
	if not was_on_wall and is_on_wall():
		if jump_buffered:
			wall_jump()
			jump_buffered = false	
	
	# Coyote jump
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	just_wall_jumped = false	
	
	# Wall jump grace period
	just_left_wall = was_on_wall and not is_on_wall()
	if just_left_wall:
		wall_jump_timer.start()
	
	
	# counting frames until slide starts
	if not is_on_wall_only():
		frames_on_wall = 0
	else:
		frames_on_wall += 1
	
	if input_axis != 0.0:
		last_input_axis = input_axis
		
		
	handle_land(was_on_floor)
	
#### Animations
		
func update_animations(input_axis):
	if input_axis != 0:
		animated_sprite_2d.flip_h = input_axis < 0
		animated_sprite_2d.play('run')
	else:
		animated_sprite_2d.play('idle')
	
	if not is_on_floor_only():
		animated_sprite_2d.play('jump')
		
	if is_on_wall_only():
		animated_sprite_2d.flip_h = input_axis > 0
		animated_sprite_2d.play('wallslide')
		
#### Movement 
	
func handle_acceleration(input_axis, delta):
	
	
	if not is_on_floor(): return
	
	if input_axis != 0 and enabled_controls:
		# Acceleration
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, (movement_data.acceleration) * delta)
	else:
		# friction 
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)
	
	
func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): return
	
	# acceleration
	velocity.x = move_toward(velocity.x, input_axis * movement_data.air_velocity, movement_data.air_acceleration * delta)
	velocity.y = move_toward(velocity.y, movement_data.speed, movement_data.air_acceleration * delta)
	
	# friction
	#velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)
	#velocity.y = move_toward(velocity.y, 0, movement_data.air_resistance * delta)
	
	
func apply_gravity(delta):
	if not is_on_floor() and not do_dash:
		velocity += get_gravity() * movement_data.gravity_scale * delta
	
func handle_jump(delta):
	if is_on_floor(): 
		air_jump = true
	
	if Input.is_action_just_pressed("jump") and enabled_controls:
		#var jump_sound = 
		#print(jump_sounds.pick_random())
		#jump_1.play()		
		jump()
		#pass
	
func jump():
	if is_on_floor() or coyote_jump_timer.time_left > 0.0: # if on the ground:
		velocity.y = movement_data.jump_velocity
	else:
		if !jump_buffered:
			jump_buffered = true
			jump_buffer_timer.start()

	if not is_on_floor() and not is_on_wall():  # if we are in the air
		if Input.is_action_just_released("jump") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2  # half jump
	else: return
	
func _on_jump_buffer_timer_timeout() -> void:
	jump_buffered = false
	#print('jump buffered false')
	
func handle_land(was_on_floor):
	if not was_on_floor and is_on_floor():
		print('landed')
		
		#play_random_sound(land_sounds)

func play_random_sound(sound_list):
	var random_index = randi() % sound_list.size()
	var random_sound = sound_list[random_index]
	random_sound.play()

	
	
	
func handle_wall_jump(input_axis):
	if not is_on_wall_only() and wall_jump_timer.time_left <= 0.0: 
		return

	if Input.is_action_just_pressed('jump'):
		
		if do_dash:
			handle_boost_wall_jump(input_axis)
		else:
	#if not do_dash and not boost_wall_jump and Input.is_action_just_pressed("jump"):
			wall_jump()
	
		
func wall_jump():
	print('wj')
	var wall_normal = get_wall_normal()
	if wall_jump_timer.time_left > 0.0:
		wall_normal = was_wall_normal
	velocity.x = wall_normal.x * movement_data.air_velocity * 1.4
	velocity.y = movement_data.jump_velocity 
	just_wall_jumped = true

func handle_boost_wall_jump(input_axis):
	boost_wall_jump = true
	print('boost wj')
	do_dash = false
	var wall_normal = get_wall_normal()
	if wall_jump_timer.time_left > 0.0:
		wall_normal = was_wall_normal
		
	input_axis = 0.0
		
	velocity.x = wall_normal.x * movement_data.air_velocity * 1.5
	velocity.y = movement_data.jump_velocity * 1.5
	just_wall_jumped = true
	boost_wall_jump = false

		
func handle_wall_slide(input_axis):
	if is_on_wall_only()  and velocity.y > 0 and input_axis != 0:
		velocity.y = 0.0
		velocity.x = 0.0
		# start slide
		if frames_on_wall > wall_slide_frames:
			velocity.y = movement_data.slide_velocity
		else:
			velocity.y = move_toward(velocity.y, 0.0, movement_data.friction)
		
		var wall_normal = get_wall_normal()
		var wall_direction = abs(wall_normal[0] - input_axis)
		
		if Input.is_action_just_pressed('jump') and wall_direction == 0:
			velocity.y = movement_data.jump_velocity
	

func is_dashing_left(input_axis) -> bool:
	return input_axis > 0.0
	
func was_dashing_left() -> bool:
	return is_dashing_left(last_input_axis)
	
#
func handle_dash(input_axis, vert_input_axis, _delta):
	if Input.is_action_just_pressed('shift') and can_dash and input_axis != 0:
			#if not is_on_wall():
				#dash_sound.play()
			last_input_axis = input_axis
			do_dash = true
			dash_duration_timer.start()
			dash_effect_timer.start()
		
	if do_dash:
		#print('dash')
		velocity.x = last_input_axis * movement_data.dash_speed
		velocity.y = 0
		#await dash_duration_timer.timeout
		can_dash = false
	
		if dink:
			do_dash = false

	if is_on_floor():
		can_dash = true
	
	

func create_dash_effect(input_axis):
	var num_orbs = 4  # Increased number of orbs for smoother effect
	var animation_time = dash_duration_timer.wait_time / 30  # Faster orb spawning
	var orb_offset = Vector2(input_axis*1, 0)  # Smaller offset for closer orbs
	var scale_factor = 0.25  # Initial scale of the orbs

	for i in range(num_orbs):
		# Create a copy of the player sprite
		var player_copy_node = animated_sprite_2d.duplicate()
		get_parent().add_child(player_copy_node)

		# Position orbs slightly offset from each other (closer together)
		player_copy_node.global_position =  global_position + (orb_offset * i)
		

		#Gradually shrink the orb size for trailing effect
		player_copy_node.scale = Vector2(scale_factor, scale_factor)
		scale_factor += 0.1 # Shrink each subsequent orb by 10%

		# Optionally, change color (e.g., from player color to light blue)
		#var color_change = Color(1, 1, 1)  # Color to transition to (e.g., white)
		##player_copy_node.modulate = player_copy_node.modulate.linear_interpolate(color_change, 0.3 * i)

		# Fade out the orb over time (smooth fade)
		fade_out_orb(player_copy_node, animation_time * 3)  # Call fade out function

		# Wait before spawning the next orb
		await get_tree().create_timer(animation_time).timeout


# Fade out function for smooth fading of orbs
func fade_out_orb(orb_node: Node2D, fade_duration: float) -> void:
	var fade_steps = 10  # More steps = smoother fading
	var fade_step_time = fade_duration / fade_steps

	for j in range(fade_steps):
		await get_tree().create_timer(fade_step_time).timeout

		# Gradually reduce opacity
		var current_modulate = orb_node.modulate
		current_modulate.a -= 0.1  # Reduce opacity in small steps
		orb_node.modulate = current_modulate

	# Queue free the orb after fading is done
	orb_node.queue_free()


		
func _on_dash_duration_timer_timeout() -> void:
	do_dash = false
	#dash_combo = false
	#do_vert_dash = false
	dash_effect_timer.stop()
	print('dash done')

func _on_dash_effect_timer_timeout() -> void:
	var input_axis := Input.get_axis("move_left", "move_right")

	if velocity.x != 0:
		create_dash_effect(input_axis)
	
func handle_dink(input_axis, delta):
		if target_position != Vector2.ZERO:
			
			dink_direction = (target_position - global_position).normalized()
			print(dink_direction)
			
			if Input.is_action_just_pressed('move_dink') and not is_on_floor() and not is_on_wall():
				player_dinked.emit("dinked")
				do_dink(dink_direction)
				dink_input_axis = input_axis  
				
				
		if input_axis != 0:
			dink_radius.position.x = input_axis * dink_radius_pos 
	
func do_dink(dink_direction):
		dink = true
		

		#print(direction)
		#dink_particles.restart()
		#dink_particles.emitting = true
		
		velocity = dink_direction * movement_data.dink_speed
		
		
		
		
		#velocity.x = dink_direction[0] * movement_data.dink_speed
		#velocity.y =  abs(dink_direction[1]) * movement_data.dink_speed  # abs so that y direction cannot be negative = downwards
		

func _on_dink_detector_body_entered(body: Node2D) -> void:
	# If player dink detector sees the dink infront of it:
	
	
	if body.is_in_group('DinkRadius'):
		#print('radius')
		target_position = body.position
		
func _on_dink_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group('DinkRadius'):
		target_position = Vector2.ZERO

func _on_dink_collision_area_entered(area: Area2D) -> void:
	if area.is_in_group('DinkCollide'):
		if dink:
			velocity.x = dink_input_axis * movement_data.dink_speed / 1.5
			velocity.y = - movement_data.dink_speed
			dink = false
	
	

func apply_death_effect() -> void:
	# Applies oneshot particle effect when player dies.
	print('emitting death particles')
	death_particles.restart()
	death_particles.emitting = true
	await death_particles.finished
	
#func ignore_input() -> void:
	
func apply_respawn_effect() -> void:
	respawn_particles.restart()
	respawn_particles.emitting = true
	await respawn_particles.finished
	
	
func emote() -> void:
	emote_animation.play("SmileEmote")
 
