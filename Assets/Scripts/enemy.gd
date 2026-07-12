extends CharacterBody2D

class_name Enemy

func die(animation_player: AnimationPlayer) -> void:
	animation_player.play('die')
	var death_animation_length: float = animation_player.current_animation_length * 2
	await get_tree().create_timer(death_animation_length).timeout
	queue_free()
