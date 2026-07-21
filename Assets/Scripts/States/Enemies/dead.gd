extends State

var enemy: Enemy

var death_sound: AudioStream

func _init() -> void:
	state_name = "dead"

func process(delta: float) -> void:
	return
	
func physics_process(delta: float) -> void:
	return
		
		
func enter() -> void:
	enemy.audio_stream_player_2d.stop()
	death_sound = load("res://Assets/Sounds/enemy_dead.wav") as AudioStream
	enemy.audio_stream_player_2d.stream = death_sound
	enemy.audio_stream_player_2d.volume_db = enemy.audio_stream_player_2d.volume_db - 10
	enemy.audio_stream_player_2d.play()
	die()
	
func exit() -> void:
	return

func die() -> void:
	enemy.dead = true
	enemy.animation_player.play('die')
	var death_animation_length: float = enemy.animation_player.current_animation_length * 2
	await get_tree().create_timer(death_animation_length).timeout
	enemy.queue_free()
