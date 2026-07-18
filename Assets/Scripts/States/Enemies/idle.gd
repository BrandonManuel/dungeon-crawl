extends State

var START_FOLLOWING_DISTANCE: float = 150.0

var enemy: Enemy
var players: Array[CharacterBody2D]

var current_closest_player_distance: int
	
var move_direction: Vector2
var wander_time: float

func _init() -> void:
	state_name = "idle"

func randomize_wander():
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(1, 3)
	
func process(delta: float) -> void:
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()
	
func physics_process(delta: float) -> void:
	if enemy:
		enemy.velocity = move_direction * enemy.SPEED
		

	for player in players:
		var distance = player.global_position - enemy.global_position
		if distance.length() < START_FOLLOWING_DISTANCE:
			Transitioned.emit(self, "Follow")
		
func enter() -> void:
	var player_nodes = get_tree().get_nodes_in_group('player')
	for player_node in player_nodes:
		players.push_back(player_node as CharacterBody2D)
			
	randomize_wander()
	
	
func exit() -> void:
	return
	
