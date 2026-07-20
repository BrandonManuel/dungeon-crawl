extends State

var enemy: Enemy

func _init() -> void:
	state_name = "attack"

func process(delta: float) -> void:
	return
	
func physics_process(delta: float) -> void:
	enemy.knockback = enemy.knockback.move_toward(Vector2.ZERO, enemy.KNOCKBACK_DECAY * delta)
	enemy.velocity = enemy.knockback
	if enemy.animation_player.current_animation == 'attack' and enemy.animation_player.is_playing():
		return
	
	if enemy.navigation_agent_2d.node_target != null:
		attack()
		
func enter() -> void:
	attack()
	
func exit() -> void:
	return

func attack() -> void:
	enemy.animation_player.play('attack_up')
