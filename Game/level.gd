extends Node2D

class_name Level

#HouseKeeping
@export var print_world_events: bool = false

# Variables
@onready var death_count: int = 0
#@onready var is_processing_death = false
@onready var processing_death: Timer = $Processing_death

@export var next_scene: PackedScene

var player_action

var spawn_point: Vector2
var dink_shake_noise: FastNoiseLite

func _ready() -> void:	
	connect_children(self)
	
	dink_shake_noise = FastNoiseLite.new()
	
	
func connect_children(parent):
	for child in parent.get_children():
		# Connecting Spawnpoints
		if child is Spawn and is_instance_valid(child):
			child.player_detected.connect(set_spawn_point)
			if print_world_events: print('spawn connected')
		
		# Connecting Dinks
		if child is Dink and is_instance_valid(child):
			child.player_detected.connect(dink_juice)
			if print_world_events: print('dink connected')
		
		# Connecting spikes
		if child is Spike and is_instance_valid(child):
			child.player_detected.connect(respawn)
			if print_world_events: print('spike connected')
			
		if child is Goal and is_instance_valid(child):
			child.player_detected.connect(reached_goal)
			if print_world_events: print('goal connectedd')

		if child is Player and is_instance_valid(child):
			child.player_dinked.connect(interpret_player_action)

		# Recursively check the children of each node
		if child.has_method("get_children"):
			connect_children(child)

#func connect_player_actions():
	#player_dinked.connect(interpret_player_action)

func _process(delta: float) -> void:
	#print(player.position)
	$UI/DeathCounter.text = str(death_count)
	
	
func interpret_player_action(action):
	player_action = action
	#await get_tree().create_timer(0.1).timeout # Small delay to ensure signal is processed
	#player_action = null # Reset so it only triggers on actual dink
	

	
	
func set_spawn_point(spawn):
	if spawn_point != spawn.global_position:
		spawn_point = spawn.global_position
		print('spawn set')
	


func respawn(spikes):
	
	if processing_death.time_left > 0.0:
		print('death already processed')
		return
	
	processing_death.start() # Timer runs always.
	
	$Player.velocity.x = 0.0
	#set_process_input(false)
	get_tree().paused = true
	$Player/AnimatedSprite2D.visible = false
	$Player.apply_death_effect()
	death_count += 1
	await get_tree().create_timer(0.5).timeout
	$Player.position = spawn_point
	$Player.apply_respawn_effect()
	await get_tree().create_timer(0.5).timeout
	$Player/AnimatedSprite2D.visible = true
	#Input.flush_buffered_events()
	#await get_tree().create_timer(0.5).timeout
	get_tree().paused = false
	#set_process_input(true)

	

func reached_goal(goal):
	$Player.emote()
	#get_tree().paused = true
	$Player.enabled_controls = false
	print('changing scene!')
	await get_tree().create_timer(0.5).timeout
	if next_scene is PackedScene:
		#get_tree().paused = false
		await LevelTransition.fade_to_black()
		get_tree().change_scene_to_packed(next_scene)
		$Player.enabled_controls = true
		LevelTransition.fade_from_black()
	else:
		get_tree().quit()
	
func dink_juice(dink):
	print('dink juice!')
	if player_action == "dinked":
		
		dink.apply_bounce_effect()
		player_action = null
		
		
func start_dink_shake(dink, scale_value) -> void:
	dink.scale = Vector2(scale_value, scale_value)
