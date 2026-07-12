extends Enemy

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

@export var KNOCKBACK_DECAY: float = 1000.0
var knockback: Vector2

const SPEED = 10.0

var players: Array[CharacterBody2D]

func _ready() -> void:
	var player_nodes = get_tree().get_nodes_in_group('player')
	for player_node in player_nodes:
		players.push_back(player_node as CharacterBody2D)

func _physics_process(delta: float) -> void:
	var target: Vector2
	var current_closest_player_distance: int
	for player in players:
		var distance: float = global_position.distance_to(player.global_position)
		if target == Vector2.ZERO or distance < current_closest_player_distance:
			current_closest_player_distance = distance
			target = player.global_position
			
	if target != null:
		navigation_agent_2d.target_position = target
		var next_path_pos := navigation_agent_2d.get_next_path_position()
		var direction: Vector2 = global_position.direction_to(next_path_pos)
		var walk_velocity: Vector2 = direction * SPEED
		
		knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * delta)
		
		velocity = walk_velocity + knockback

		if knockback != Vector2.ZERO:
			print('Walk velocity: ', walk_velocity)
			print('Knockback: ', knockback)
			
		if direction.y < 0:
			animated_sprite_2d.play("move_up")
		else:
			animated_sprite_2d.play("move_down")
		if direction.x < 0:
			animated_sprite_2d.flip_h = true
		else:
			animated_sprite_2d.flip_h = false
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		
	move_and_slide()
	

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		print("hitting player")


func _on_hit_box_body_exited(body: Node2D) -> void:
	if body.is_in_group('player'):
		print("no longer hitting player")

func is_hit(force: Vector2) -> void:
	knockback = force
