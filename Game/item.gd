extends StaticBody2D

class_name Item

signal player_detected

# Item lives on layer 1 (world), looks at layer 2 (Player)

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		print('player detected on ', self.name)
		handle_player_event(body)
		player_detected.emit(self)

func handle_player_event(body: Node2D) -> void:
	pass
