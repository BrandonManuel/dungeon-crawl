extends Enemy

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var goblin_navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var death_sprite: Sprite2D = $DeathSprite
@onready var goblin_animation_player: AnimationPlayer = $AnimationPlayer
@onready var goblin_audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var attack_range_collision_shape_2d: CollisionShape2D = $AttackRange/CollisionShape2D
@onready var goblin_sprite_2d: Sprite2D = $Sprite2D
@onready var attack_sprite_2d: Sprite2D = $Attack
@onready var goblin_state_machine: StateMachine = $StateMachine
@onready var detection_radius: Area2D = $DetectionRadius
@onready var hitbox: HitBoxArea2D = $Attack/Hitbox
@onready var death_cpu_particles_2d: CPUParticles2D = $DeathCPUParticles2D
@onready var hit_cpu_particles_2d: CPUParticles2D = $HitCPUParticles2D

@export var hit_preset: ParticlePreset
@export var death_preset: ParticlePreset

var parried_sound = load("res://Assets/Sounds/enemy_parried.wav") as AudioStream
var hit_sound = load("res://Assets/Sounds/enemy_hit.wav") as AudioStream
var critical_hit_sound = load("res://Assets/Sounds/enemy_hit_critical.wav") as AudioStream

@export var	GOBLIN_KNOCKBACK_DECAY = 1000.0
@export var	GOBLIN_SPEED = 10.0
@export var	GOBLIN_HEALTH = 20.0
@export var	GOBLIN_DAMAGE = 10.0
@export var	GOBLIN_KNOCKBACK = 1.0
@export var GOBLIN_ATTACK_COOLDOWN_SECONDS = 0.0
@export var GOBLIN_TIMER: Timer
@export var GOBLIN_IDLE_PAUSE_CHANCE: int

var players: Array[CharacterBody2D]
var cameras: Array[Camera2D]

signal was_hit
signal was_parried
signal died

var starting_volume: float
	
func _apply_preset(preset: ParticlePreset, particles: CPUParticles2D) -> void:
	for prop in preset.get_property_list():
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			particles.set(prop.name, preset.get(prop.name))
		
func _ready() -> void:
	KNOCKBACK_DECAY = GOBLIN_KNOCKBACK_DECAY
	SPEED = GOBLIN_SPEED
	max_health = GOBLIN_HEALTH
	current_health = GOBLIN_HEALTH
	damage = GOBLIN_DAMAGE
	knockback = GOBLIN_KNOCKBACK
	attack_cooldown_seconds = GOBLIN_ATTACK_COOLDOWN_SECONDS
	timer = GOBLIN_TIMER
	state_machine = goblin_state_machine
	idle_pause_chance = GOBLIN_IDLE_PAUSE_CHANCE
	
	var player_nodes = get_tree().get_nodes_in_group('player')
	for player_node in player_nodes:
		players.push_back(player_node as CharacterBody2D)
		
	for player in players:
		cameras.push_back(player.get_node('Camera2D') as Camera2D)
		
	animation_player = goblin_animation_player
	navigation_agent_2d = goblin_navigation_agent_2d
	sprite_2d = goblin_sprite_2d
	audio_stream_player_2d = goblin_audio_stream_player_2d
	
	hitbox.damage = damage
	hitbox.knockback = knockback
		
	_apply_preset(hit_preset, hit_cpu_particles_2d)
	_apply_preset(death_preset, death_cpu_particles_2d)
	starting_volume = audio_stream_player_2d.volume_db
	
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
	if dead:
		return
		
	if parried:
		damage = damage * 1.5
		
	current_health -= damage
	var current_hit_cpu_particles: CPUParticles2D = hit_cpu_particles_2d
#	if current hit particles are emitting, temporarily make a new one
#	keep this in mind as a future optimization if it's a performance concern at any point
	if current_hit_cpu_particles.emitting:
		current_hit_cpu_particles = current_hit_cpu_particles.duplicate()
		current_hit_cpu_particles.one_shot = true
		hit_cpu_particles_2d.add_sibling(current_hit_cpu_particles)
		current_hit_cpu_particles.restart()
		current_hit_cpu_particles.emitting = true
		current_hit_cpu_particles.finished.connect(current_hit_cpu_particles.queue_free)
	hit_cpu_particles_2d.gravity = force
	hit_cpu_particles_2d.direction = force.normalized()
	if current_health <= 0:
		current_health = 0
		died.emit()
	else:
		was_hit.emit(force, parried)
	
	if current_health <= 0 and parried:
		#	chance to focus camera
		if randi_range(0, 1):
			critical_zoom()

func is_parried(force: Vector2) -> void:
	was_parried.emit(force)

func disable_collision() -> void:
	collision_shape_2d.disabled = true
	
func enable_hitbox() -> void:
	attack_range_collision_shape_2d.disabled = false
	
func disable_hitbox() -> void:
	attack_range_collision_shape_2d.disabled = true

func critical_zoom() -> void:
	if cameras.size() == 1:
		var camera: Camera2D = cameras.get(0)
		var prev_parent := camera.get_parent()
		if (prev_parent as Player).critical_zoom:
			return
		
		(prev_parent as Player).critical_zoom = true
		audio_stream_player_2d.volume_db = 6.0 
		audio_stream_player_2d.stream = critical_hit_sound
		audio_stream_player_2d.play()
		Engine.time_scale = 0.5
		audio_stream_player_2d.pitch_scale = .5
		var prev_zoom := camera.zoom

		var tween_in = camera.create_tween().set_parallel(true)
		camera.set_position_smoothing_enabled(false)
		tween_in.tween_property(camera, "global_position", global_position, .1)
		tween_in.tween_property(camera, "zoom", Vector2(2.5, 2.5), .25)
		await tween_in.finished
		
		await get_tree().create_timer(.5).timeout
		
		#var tween_out = camera.create_tween().set_parallel(true)
		#tween_out.tween_property(camera, "global_position", prev_parent.global_position, .1)
		#tween_out.tween_property(camera, "zoom", prev_zoom, .25)
		camera.global_position = prev_parent.global_position
		camera.zoom = prev_zoom
		Engine.time_scale = 1.0
		audio_stream_player_2d.pitch_scale = 1.0
		#await tween_out.finished
		camera.set_position_smoothing_enabled(true)
		(prev_parent as Player).critical_zoom = false
		
func _on_was_hit(force: Vector2, critical: bool) -> void:
	audio_stream_player_2d.stop()
	received_knockback = force
	audio_stream_player_2d.stream = hit_sound
	audio_stream_player_2d.play()
	animation_player.play("hit")
	call_deferred("disable_hitbox")
	hit = true
	var hit_animation_length: float = animation_player.current_animation_length
	await get_tree().create_timer(hit_animation_length).timeout
	hit = false
	call_deferred("enable_hitbox")

func _on_was_parried(force: Vector2) -> void:
	received_knockback = force
	animation_player.play("parried")
	parried = true
	var parried_animation_length: float = animation_player.current_animation_length
	audio_stream_player_2d.stop()
	audio_stream_player_2d.stream = parried_sound
	audio_stream_player_2d.play()
	await get_tree().create_timer(parried_animation_length).timeout
	parried = false


func _on_audio_stream_player_2d_finished() -> void:
	audio_stream_player_2d.volume_db = starting_volume
