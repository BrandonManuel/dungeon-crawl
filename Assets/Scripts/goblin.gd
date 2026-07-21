extends Enemy

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var goblin_navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var death_sprite: Sprite2D = $DeathSprite
@onready var goblin_animation_player: AnimationPlayer = $AnimationPlayer
@onready var goblin_audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var attack_range_collision_shape_2d: CollisionShape2D = $AttackRange/CollisionShape2D
@onready var goblin_sprite_2d: Sprite2D = $Sprite2D
@onready var attack_sprite_2d: Sprite2D = $Attack
@onready var state_machine: StateMachine = $StateMachine
@onready var detection_radius: Area2D = $DetectionRadius
@onready var hitbox: HitBoxArea2D = $Attack/Hitbox

var knockback: Vector2

var players: Array[CharacterBody2D]

signal was_hit
signal died

func _ready() -> void:
	var player_nodes = get_tree().get_nodes_in_group('player')
	for player_node in player_nodes:
		players.push_back(player_node as CharacterBody2D)
		
	animation_player = goblin_animation_player
	navigation_agent_2d = goblin_navigation_agent_2d
	sprite_2d = goblin_sprite_2d
	audio_stream_player_2d = goblin_audio_stream_player_2d
	
	hitbox.damage = damage
	return

func _process(delta: float) -> void:
	if dead:
		return
		
	if state_machine:
		state_machine.process(delta)
		
func _physics_process(delta: float) -> void:
	if dead:
		return
		
	if state_machine:
		state_machine.physics_process(delta)
		
	move_and_slide()
	
func is_hit(force: Vector2, damage: float) -> void:
	health -= damage
	if health <= 0:
		died.emit()
	else:
		was_hit.emit(force)

func disable_collision() -> void:
	collision_shape_2d.disabled = true
	
func disable_hitbox() -> void:
	attack_range_collision_shape_2d.disabled = true

func _on_was_hit(force: Vector2) -> void:
	knockback = force
	animation_player.call_deferred("play", "hit")
	set_deferred('hit', true)
	var hit_animation_length: float = animation_player.current_animation_length
	await get_tree().create_timer(hit_animation_length).timeout
	hit = false
