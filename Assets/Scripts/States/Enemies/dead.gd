extends State

var enemy: Enemy

func _init() -> void:
	state_name = "dead"

func process(delta: float) -> void:
	return
	
func physics_process(delta: float) -> void:
	return
		
		
func enter() -> void:
	die()
	
func exit() -> void:
	return

func die() -> void:
	enemy.dead = true
	enemy.animation_player.play('die')
	var death_animation_length: float = enemy.animation_player.current_animation_length * 2
	await get_tree().create_timer(death_animation_length).timeout
	enemy.queue_free()
