extends Enemy

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var death_sprite: Sprite2D = $DeathSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_box_collision_shape_2d: CollisionShape2D = $HitBox/CollisionShape2D
@onready var state_machine: StateMachine = $StateMachine

@export var KNOCKBACK_DECAY: float = 0.0

@export var health: float = 20.0

var knockback: Vector2

var players: Array[CharacterBody2D]

var hit: bool = false
var dead: bool = false

signal was_hit
signal died

func _ready() -> void:
	var player_nodes = get_tree().get_nodes_in_group('player')
	for player_node in player_nodes:
		players.push_back(player_node as CharacterBody2D)
		
	return

func _physics_process(delta: float) -> void:
	if dead:
		return
		
	if state_machine.current_state:
		state_machine.current_state.physics_process(delta)
	
	move_and_slide()
	

func _on_hit_box_body_entered(body: Node2D) -> void:
	if not dead and body.is_in_group('player'):
		print("hitting player")


func _on_hit_box_body_exited(body: Node2D) -> void:
	if not dead and body.is_in_group('player'):
		print("no longer hitting player")

func is_hit(force: Vector2, damage: float) -> void:
	health -= damage
	if health <= 0:
		died.emit()
		call_deferred('disable_collision')
		call_deferred('disable_hitbox')
	else:
		was_hit.emit()
		knockback = force
		call_deferred('disable_hitbox_for_hit')

func disable_collision() -> void:
	collision_shape_2d.disabled = true
	
func disable_hitbox() -> void:
	hit_box_collision_shape_2d.disabled = true
	
func disable_hitbox_for_hit() -> void:
	animation_player.play('hit')
	hit_box_collision_shape_2d.disabled = true
	hit = true
	var hit_animation_length: float = animation_player.current_animation_length
	await get_tree().create_timer(hit_animation_length).timeout
	hit_box_collision_shape_2d.disabled = false
	hit = false
