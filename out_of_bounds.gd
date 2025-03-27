extends Node2D





func _on_hazard_area_body_entered(_body: Node2D) -> void:
	Events.out_of_bounds.emit()
	
