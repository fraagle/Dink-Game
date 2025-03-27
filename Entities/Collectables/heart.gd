extends Area2D


func _on_body_entered(_body: Node2D) -> void:
	queue_free()
	var hearts = get_tree().get_nodes_in_group('Hearts')
	var hearts_left = hearts.size() - 1
	print(hearts_left)
	
	if hearts_left == 0:
		print('level completed')

		Events.level_completed.emit()
