extends Node

class_name StateMachine

@export var states_scenes: Array[GDScript] = []
@export var enemy: Enemy

var player_target: Player

var current_state: State

var states: Dictionary = {}

var initial_speed: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var initial_state: State
	for state_scene in states_scenes:
		var state = state_scene.new()
		add_child(state)
		if state is State:
			states[state.state_name.to_lower()] = state
			state.enemy = enemy
			state.Transitioned.connect(on_state_transition)
			if initial_state == null:
				initial_state = state
				
	if enemy:
		initial_speed = enemy.SPEED
		
	initial_state.enter()
	current_state = initial_state

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta: float) -> void:
	if current_state:
		current_state.process(delta)


func physics_process(delta: float) -> void:
	if !current_state:
		return
		
#	dead is a terminal state
	if current_state.state_name.to_lower() == 'dead':
		current_state.physics_process(delta)
		return
		
#   if player target has died, go back to idle
	if player_target and player_target.dead:
		current_state.Transitioned.emit(current_state, "idle")
#	follow player if there is a player target, player is in sightline, player is alive, and I am not currently attacking nor following
	if player_target and not  player_target.dead and current_state.state_name.to_lower() != "follow" and not current_state.state_name.to_lower().contains( "attack"):
		var sight_line: RayCast2D = enemy.get_node("DetectionRadius").get_node("RayCast2D")
		sight_line.global_position = enemy.global_position
		sight_line.target_position = player_target.global_position - enemy.global_position
		var collider = sight_line.get_collider()
		var navigation_agent_2d = enemy.get_node("NavigationAgent2D") as Node2DTrackingNavigationAgent2D
		if collider is Player:
			current_state.Transitioned.emit(current_state, "follow")
#	idle if no player target and I am currently following
	elif not player_target and current_state.state_name.to_lower() == "follow":
		var navigation_agent_2d: Node2DTrackingNavigationAgent2D = enemy.get_node("NavigationAgent2D")
		if navigation_agent_2d.node_target is Player:	
			current_state.Transitioned.emit(current_state, "idle")
			
	current_state.physics_process(delta)

func on_state_transition(state: State, new_state_name: String) -> void :
	if state.state_name == new_state_name:
		return
		
	if enemy.dead:
		return
		
	if state != current_state:
		return
		
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
			
#	if going from attack to follow, finish attack first
	if state.state_name == 'attack' and new_state_name == 'follow':
		var attack_animation_length: float = enemy.animation_player.current_animation_length - enemy.animation_player.current_animation_position
		await get_tree().create_timer(attack_animation_length).timeout
		#	only go from attack to follow if enemy is still outside of attack range
		var attack_range: Area2D = enemy.get_node('AttackRange')
		var overlapping_bodies = attack_range.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body is Player:
				return
				
	if current_state:
		current_state.exit()

	new_state.enter()
	print('CHANGING FROM ', state.state_name, ' TO ', new_state_name)
	current_state = new_state


# signals overwrite state immediately - normal state machine transitions do not apply
func _on_enemy_dead() -> void:
	current_state.Transitioned.emit(current_state, "dead")

func _on_detection_radius_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	
	if "dead" in body and body.dead:
		return
		
	player_target = body

func _on_detection_radius_body_exited(body: Node2D) -> void:
	if player_target == body:
		player_target = null
	
# start attacking when player enters attack range
func _on_attack_range_body_entered(body: Node2D) -> void:
	if not enemy.dead and body.is_in_group("player") and "dead" in body:
		if body.dead:
			print(body, ' is dead already so leaving')
			return
			
		if body not in enemy.attack_targets:
			enemy.attack_targets.push_back(body)
		current_state.Transitioned.emit(current_state, "attack")

# stop attacking when player leaves attack range
func _on_leave_attack_range_body_exited(body: Node2D) -> void:
	if not enemy.dead and body.is_in_group('player') and body in enemy.attack_targets:
		enemy.attack_targets.remove_at(enemy.attack_targets.find(body))
		if enemy.attack_targets.size() == 0:
			current_state.Transitioned.emit(current_state, "follow")
