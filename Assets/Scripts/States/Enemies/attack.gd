extends State

var enemy: Enemy

func _init() -> void:
	state_name = "attack"

func process(delta: float) -> void:
	return
	
func physics_process(delta: float) -> void:
	enemy.received_knockback = enemy.received_knockback.move_toward(Vector2.ZERO, enemy.KNOCKBACK_DECAY * delta)
	enemy.velocity = enemy.received_knockback
	if enemy.animation_player.current_animation.contains('attack') and enemy.animation_player.is_playing():
		return
	
	if enemy.hit or enemy.parried:
		return
		
	if enemy.navigation_agent_2d.node_target != null and enemy.state_machine.can_attack:
		attack()
		
func enter() -> void:
	print('enter attack')
	if not enemy.state_machine.can_attack:
		return
		
	print('attacking')
	attack()
	
func exit() -> void:
	return

func attack() -> void:
	if enemy.player_direction.x < 0:
		enemy.sprite_2d.flip_h = true
		enemy.attack_sprite_2d.flip_h = true
	else:
		enemy.sprite_2d.flip_h = false
		enemy.attack_sprite_2d.flip_h = false
	
	# TODO why not just set timer for attack + cooldown right away instead of the 2
	# separate cooldown callbacks? Also could add small visual to show when
	# enemy is on cooldown maybe
	enemy.animation_player.play('attack_up')
	enemy.state_machine.can_attack = false
	if enemy.timer != null:
		enemy.timer.one_shot = true
		var attack_length = enemy.animation_player.current_animation_length
		enemy.timer.timeout.connect(enemy.state_machine.on_attack_finished)
		enemy.timer.start(attack_length)
