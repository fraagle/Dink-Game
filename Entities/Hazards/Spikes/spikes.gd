extends Node2D


#@onready var player: CharacterBody2D = $"../../Player"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_hazard_area_body_entered(_body: Node2D) -> void:
	
	Events.death.emit()
	#player.position = spawn_position
