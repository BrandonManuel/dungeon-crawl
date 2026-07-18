extends Node

class_name StateMachine

@export var states_scenes: Array[GDScript] = []
@export var enemy: Enemy

var player_target: Player

var current_state: State

var states: Dictionary = {}

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
				
	initial_state.enter()
	current_state = initial_state

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_state:
		current_state.process(delta)


func  _physics_process(delta: float) -> void:
	if player_target and current_state.state_name.to_lower() != "follow":
		var sight_line: RayCast2D = enemy.get_node("DetectionRadius").get_node("RayCast2D")
		sight_line.global_position = enemy.global_position
		sight_line.target_position = player_target.global_position - enemy.global_position
		var collider = sight_line.get_collider()
		var navigation_agent_2d = enemy.get_node("NavigationAgent2D") as Node2DTrackingNavigationAgent2D
		if collider is Player:
			current_state.Transitioned.emit(current_state, "follow")
	elif not player_target and current_state.state_name.to_lower() == "follow":
		var navigation_agent_2d: Node2DTrackingNavigationAgent2D = enemy.get_node("NavigationAgent2D")
		if navigation_agent_2d.node_target is Player:	
			current_state.Transitioned.emit(current_state, "idle")
			
	if current_state:
		current_state.physics_process(delta)

func on_state_transition(state: State, new_state_name: String) -> void :
	print('CHANGING FROM ', state.state_name, ' TO ', new_state_name)
	if state != current_state:
		return
		
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
		
	if current_state:
		current_state.exit()

	new_state.enter()
	
	current_state = new_state


func _on_enemy_dead() -> void:
	current_state.Transitioned.emit(current_state, "dead")

func _on_detection_radius_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	
	player_target = body

func _on_detection_radius_body_exited(body: Node2D) -> void:
	if player_target == body:
		player_target = null
