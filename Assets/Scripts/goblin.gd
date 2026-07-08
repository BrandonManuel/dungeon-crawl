extends Enemy

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 10.0

var players: Array[CharacterBody2D]

func _ready() -> void:
	var player_nodes = get_tree().get_nodes_in_group('player')
	for player_node in player_nodes:
		players.push_back(player_node as CharacterBody2D)

func _physics_process(delta: float) -> void:
	var direction: Vector2
	var current_closest_player_distance: int
	for player in players:
		var distance: float = global_position.distance_to(player.global_position)
		if direction == Vector2.ZERO or distance < current_closest_player_distance:
			direction = global_position.direction_to(player.global_position)
			
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
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
