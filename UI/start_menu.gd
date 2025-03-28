extends CenterContainer

@onready var start_game_button: Button = %StartGameButton
@onready var quit_game_button: Button = %QuitGameButton

@export var next_scene: PackedScene

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	start_game_button.grab_focus()

func _on_start_game_button_pressed() -> void:
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_packed(next_scene)
	LevelTransition.fade_from_black()
	
func _on_quit_game_button_pressed() -> void:
	get_tree().quit()
