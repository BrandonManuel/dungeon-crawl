extends State

var STOP_FOLLOWING_DISTANCE: float = 150.0

var enemy: Enemy
var player_nodes: Array[Node]

func _init() -> void:
	state_name = "follow"

func process(delta: float) -> void:
	return
	
func physics_process(delta: float) -> void:
	if not player_nodes or player_nodes.size() == 0:
		player_nodes = get_tree().get_nodes_in_group('player')
	
	var target: Vector2
	var target_node: Node2D
	var current_closest_player_distance: int
	for player_node in player_nodes:
		var player = player_node as CharacterBody2D
		var distance: float = enemy.global_position.distance_to(player.global_position)
		if target == Vector2.ZERO or distance < current_closest_player_distance:
			current_closest_player_distance = distance
			target = player.global_position
			target_node = player
			
	if target != null:
		var navigation_agent_2d = enemy.navigation_agent_2d as Node2DTrackingNavigationAgent2D
		navigation_agent_2d.target_position = target
		navigation_agent_2d.node_target = target_node
		var next_path_pos := navigation_agent_2d.get_next_path_position()
		var direction: Vector2 = enemy.global_position.direction_to(next_path_pos)
		var walk_velocity: Vector2 = direction * enemy.SPEED
		
		enemy.knockback = enemy.knockback.move_toward(Vector2.ZERO, enemy.KNOCKBACK_DECAY * delta)
		
		enemy.velocity = walk_velocity + enemy.knockback

		if !enemy.hit:
			if direction.y < 0:
				enemy.animation_player.play("move_up")
			else:
				enemy.animation_player.play("move_down")
			if direction.x < 0:
				enemy.sprite_2d.flip_h = true
				enemy.attack_sprite_2d.flip_h = true
			else:
				enemy.sprite_2d.flip_h = false
				enemy.attack_sprite_2d.flip_h = false
	else:
		Transitioned.emit(self, "idle")
		
func enter() -> void:
	return
	
	
func exit() -> void:
	var navigation_agent_2d = enemy.navigation_agent_2d as NavigationAgent2D
	navigation_agent_2d.target_position = enemy.global_position
	var _flush = navigation_agent_2d.get_next_path_position() 
