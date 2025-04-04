extends Item


class_name Dink

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func apply_bounce_effect()->void:
	collision_shape_2d.disabled = false
	animation_player.play('Dink_Bounce')
	await get_tree().create_timer(0.5).timeout
	collision_shape_2d.disabled = true
