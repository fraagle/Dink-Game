extends Node2D


@export var next_level: PackedScene 
@onready var player: CharacterBody2D = $Player


#@onready var polygon_2d: Polygon2D = $StaticBody2D/CollisionPolygon2D/Polygon2D
#@onready var collision_polygon_2d: CollisionPolygon2D = $StaticBody2D/CollisionPolygon2D
@onready var level_completed: ColorRect = $CanvasLayer/LevelCompleted

#@onready var death_message: CenterContainer = $DeathMessage

# Start in screen
@onready var start_in: ColorRect = %StartIn
@onready var start_in_label: Label = %StartInLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var set_spawn_point = player.position

func _ready():  # runs when world node is ready. Start of the game
	
	#
	#Events.level_completed.connect(show_level_completed)
	#
	#get_tree().paused = true
	#LevelTransition.fade_from_black()
	#animation_player.play('count_down')
	#await animation_player.animation_finished
	#get_tree().paused = false
	#
	RenderingServer.set_default_clear_color(Color.BLACK)
	#polygon_2d.polygon = collision_polygon_2d.polygon
	Events.death.connect(player_death)
	Events.out_of_bounds.connect(player_out_of_bounds)
	Events.set_spawn.connect(spawn_player)
	
func show_level_completed():
	#level_completed.show()
	get_tree().paused = true
	#
	await get_tree().create_timer(0.8).timeout
	
	if not next_level is PackedScene:
		return
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	
	
func player_death():
	player.position = set_spawn_point
	
#func _on_area_2d_body_entered(body: Node2D) -> void:
	##if (body.name == 'Player'):
	##get_tree().paused = false
	#get_tree().change_scene_to_packed(next_level)

func player_out_of_bounds():
	player.position = set_spawn_point

#func _on_player_entered_detector_body_entered(body: Node2D) -> void:
	#Events.room_entered.emit(self)

func spawn_player():
	#print('spawn-set')
	set_spawn_point = player.position
	
