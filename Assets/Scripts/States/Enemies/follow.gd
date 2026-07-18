extends State

var STOP_FOLLOWING_DISTANCE: float = 150.0

var enemy: Enemy

func _init() -> void:
	state_name = "follow"

func process(delta: float) -> void:
	return
	
func physics_process(delta: float) -> void:
	var player_nodes = get_tree().get_nodes_in_group('player')
		
	var target: Vector2
	var current_closest_player_distance: int
	for player_node in player_nodes:
		var player = player_node as CharacterBody2D
		var distance: float = enemy.global_position.distance_to(player.global_position)
		if target == Vector2.ZERO or distance < current_closest_player_distance:
			current_closest_player_distance = distance
			target = player.global_position
			
	if target != null:
		var navigation_agent_2d = enemy.navigation_agent_2d as NavigationAgent2D
		navigation_agent_2d.target_position = target
		var next_path_pos := navigation_agent_2d.get_next_path_position()
		var direction: Vector2 = enemy.global_position.direction_to(next_path_pos)
		var walk_velocity: Vector2 = direction * enemy.SPEED
		
		enemy.knockback = enemy.knockback.move_toward(Vector2.ZERO, enemy.KNOCKBACK_DECAY * delta)
		
		enemy.velocity = walk_velocity + enemy.knockback

		if !enemy.hit:
			if direction.y < 0:
				enemy.animated_sprite_2d.play("move_up")
			else:
				enemy.animated_sprite_2d.play("move_down")
			if direction.x < 0:
				enemy.animated_sprite_2d.flip_h = true
			else:
				enemy.animated_sprite_2d.flip_h = false
		
		var distance = target - enemy.global_position
		if distance.length() > STOP_FOLLOWING_DISTANCE:
			Transitioned.emit(self, "idle")
	else:
		Transitioned.emit(self, "idle")
		
func enter() -> void:
	return
	
	
func exit() -> void:
	var navigation_agent_2d = enemy.navigation_agent_2d as NavigationAgent2D
	navigation_agent_2d.target_position = Vector2.ZERO
