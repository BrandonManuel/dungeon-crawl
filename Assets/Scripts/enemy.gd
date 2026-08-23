extends Actor

class_name Enemy

var received_knockback: Vector2
var sprite_2d: Sprite2D
var animation_player: AnimationPlayer
var navigation_agent_2d: Node2DTrackingNavigationAgent2D
var audio_stream_player_2d: AudioStreamPlayer2D
var hit: bool = false
var parried: bool = false
var dead: bool = false
var attack_targets: Array[Player] = []

func is_parried(force: Vector2) -> void:
	print('default is_parried')
