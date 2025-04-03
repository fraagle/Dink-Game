extends Item


class_name Dink

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func apply_bounce_effect()->void:
	animation_player.play('Dink_Bounce')
