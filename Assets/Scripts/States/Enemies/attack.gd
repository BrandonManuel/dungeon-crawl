extends State

var enemy: Enemy

func _init() -> void:
	state_name = "attack"

func process(delta: float) -> void:
	return
	
func physics_process(delta: float) -> void:
	enemy.velocity = Vector2.ZERO
	enemy.knockback = enemy.knockback.move_toward(Vector2.ZERO, enemy.KNOCKBACK_DECAY * delta)
	var next_path_pos := enemy.navigation_agent_2d.get_next_path_position()
	var direction: Vector2 = enemy.global_position.direction_to(next_path_pos)
	var walk_velocity: Vector2 = direction * enemy.SPEED	
	enemy.velocity = walk_velocity + enemy.knockback
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
