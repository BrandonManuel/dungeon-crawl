extends Enemy

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var death_sprite: Sprite2D = $DeathSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var KNOCKBACK_DECAY: float = 0.0

@export var health: float = 20.0

var knockback: Vector2
const SPEED = 10.0

var players: Array[CharacterBody2D]

var dead: bool = false
signal died

func _ready() -> void:
	var player_nodes = get_tree().get_nodes_in_group('player')
	for player_node in player_nodes:
		players.push_back(player_node as CharacterBody2D)

func _physics_process(delta: float) -> void:
	if dead:
		return
		
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

func is_hit(force: Vector2, damage: float) -> void:
	health -= damage
	if health <= 0:
		call_deferred('disable_collision')
		animated_sprite_2d.visible = false
		death_sprite.visible = true
		dead = true
		died.emit()
		die(animation_player)
	else:
		knockback = force

func disable_collision() -> void:
	collision_shape_2d.disabled = true
