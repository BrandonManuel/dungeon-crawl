extends Weapon

@onready var collision_shape_2d: CollisionShape2D = $Effect/Slash/Area2D/CollisionShape2D
@onready var slash: Sprite2D = $Effect/Slash
@onready var effect: Node2D = $Effect
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var knockback: float
@export var damage: float
@export var pitch_shift_low: float
@export var pitch_shift_high: float

var slash_global_position: Vector2
var slash_local_position: Vector2

var slash_global_rotation: float
var slash_local_rotation: float

var slash_location_set: bool = false

var pitch_shift: bool = false
var pitch_shift_effect: AudioEffectPitchShift

func _ready() -> void:
	pitch_shift_effect = AudioServer.get_bus_effect(AudioServer.get_bus_index(audio_stream_player_2d.bus), 0)

func _physics_process(delta: float) -> void:
	if !enabled:
		audio_stream_player_2d.stop()
		animation_player.stop()
		animation_player.play('RESET')
		
	if slash.visible:
		if !slash_location_set:
			slash_location_set = true
			slash_global_position = effect.global_position
			slash_local_position = effect.position
			slash_global_rotation = effect.global_rotation
			
			effect.top_level = true
			effect.global_position = slash_global_position
			effect.global_rotation = slash_global_rotation
			
		collision_shape_2d.disabled = false
	else:
		if slash_location_set:
			slash_location_set = false
			effect.top_level = false
			effect.position = slash_local_position
			effect.rotation = slash_local_rotation
			collision_shape_2d.disabled = true

	if audio_stream_player_2d.playing and not pitch_shift and pitch_shift_effect != null:
		pitch_shift = true
		pitch_shift_effect.pitch_scale = randf_range(pitch_shift_low, pitch_shift_high)
		
		
	if not audio_stream_player_2d.playing and pitch_shift:
		pitch_shift = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('enemies') and body is CharacterBody2D:
		hit_enemy(body as CharacterBody2D, knockback, damage)
