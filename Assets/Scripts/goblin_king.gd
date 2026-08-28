extends Enemy

@onready var goblin_state_machine: StateMachine = $StateMachine
@onready var goblin_sprite_2d: Sprite2D = $Visual/Sprite2D
@onready var attack_sprite_2d: Sprite2D = $Visual/Attack
@onready var goblin_navigation_agent_2d: Node2DTrackingNavigationAgent2D = $NavigationAgent2D
@onready var goblin_animation_player: AnimationPlayer = $AnimationPlayer

@export var	GOBLIN_KING_KNOCKBACK_DECAY = 1000.0
@export var	GOBLIN_KING_SPEED = 30.0
@export var	GOBLIN_KING_HEALTH = 300.0
@export var	GOBLIN_KING_DAMAGE = 10.0
@export var	GOBLIN_KING_KNOCKBACK = 3.0
@export var GOBLIN_KING_ATTACK_COOLDOWN_SECONDS = 5.0
@export var GOBLIN_KING_TIMER: Timer
@export var GOBLIN_KING_IDLE_PAUSE_DENOMINATOR_CHANCE: int
@export var GOBLIN_KING_IDLE_PAUSE_CHANCE: int

func _ready() -> void:
	KNOCKBACK_DECAY = GOBLIN_KING_KNOCKBACK_DECAY
	SPEED = GOBLIN_KING_SPEED
	max_health = GOBLIN_KING_HEALTH
	current_health = GOBLIN_KING_HEALTH
	damage = GOBLIN_KING_DAMAGE
	knockback = GOBLIN_KING_KNOCKBACK
	attack_cooldown_seconds = GOBLIN_KING_ATTACK_COOLDOWN_SECONDS
	timer = GOBLIN_KING_TIMER
	state_machine = goblin_state_machine
	animation_player = goblin_animation_player
	navigation_agent_2d = goblin_navigation_agent_2d
	sprite_2d = goblin_sprite_2d
	#audio_stream_player_2d = goblin_audio_stream_player_2d
	idle_pause_chance = GOBLIN_KING_IDLE_PAUSE_CHANCE
	
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
