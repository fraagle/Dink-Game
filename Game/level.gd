extends Node2D

class_name level

#HouseKeeping
@export var print_world_events: bool = false

# Exports
@export var next_scene: PackedScene

# Variables
@onready var death_count: int = 0


var spawn_point: Vector2


func _ready() -> void:	
	connect_children(self)
	

func connect_children(parent):
	for child in parent.get_children():
		# Connecting Spawnpoints
		if child is Spawn and is_instance_valid(child):
			child.player_detected.connect(set_spawn_point)
			if print_world_events: print('spawn connected')
		
		# Connecting spikes
		if child is Spike and is_instance_valid(child):
			child.player_detected.connect(respawn)
			if print_world_events: print('spike connected')
			
		if child is Goal and is_instance_valid(child):
			child.player_detected.connect(reached_goal)
			if print_world_events: print('goal connectedd')

		# Recursively check the children of each node
		if child.has_method("get_children"):
			connect_children(child)


func _process(delta: float) -> void:
	#print(player.position)
	$UI/DeathCounter.text = str(death_count)
	
func set_spawn_point(spawn):
	if spawn_point != spawn.global_position:
		spawn_point = spawn.global_position
		print('spawn set')
	
	
func respawn(spikes):
	$Player.position = spawn_point
	print('respawn')
	death_count += 1
	

func reached_goal(goal):
	print('changing scene!')
	
	if next_scene is PackedScene:
		await LevelTransition.fade_to_black()
		get_tree().change_scene_to_packed(next_scene)
		LevelTransition.fade_from_black()
	return
	
	
	#if not next_level:
		#respawn(self)
	#else:
		#get_tree().change_scene_to_packed(next_level)
	
	
	
