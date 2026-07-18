extends Node

class_name StateMachine

@export var states_scenes: Array[PackedScene] = []
@export var enemy: Enemy

var current_state: State

var states: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var initial_state: State
	for state_scene in states_scenes:
		var state = state_scene.instantiate()
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
	if current_state:
		current_state.physics_process(delta)

func on_state_transition(state: State, new_state_name: String) -> void :
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
