extends CharacterBody2D

class_name Player

@onready var hand: Marker2D = $Hand
@onready var animation_player: AnimationPlayer = $Visual/AnimationPlayer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var attack_delay: float = 0.0
@export var health: float = 50.0
@export var JOYSTICK_OFFSET: float = .2
@export var KNOCKBACK_DECAY: float = 1000.0
@export var BLOCK_DAMAGE_NEGATION: float = .5
@export var BLOCK_KNOCKBACK_NEGATION: float = .5

var weapon: Weapon = null
var last_held_direction: Vector2

const SPEED: float = 100.0

var movement_enabled: bool = true
var can_act: bool = true
var is_blocking: bool = false
var dead: bool = false

var death_sound: AudioStream

var received_knockback: Vector2

func _ready() -> void:
	var held = hand.get_children()
	if held.size() == 1:
		weapon = held.get(0)
		weapon.player = self
		
	set_attack_delay(attack_delay)
		
func _process(delta: float) -> void:
	if not animation_player.is_playing():
		animation_player.play("idle")
		
func _physics_process(delta: float) -> void:
	if not can_act and (animation_player.is_playing() and animation_player.current_animation.contains("attack")):
		can_act = true
		weapon.enabled = true
		
	if dead :
		return
		
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if movement_enabled:
		handle_movement(delta, direction)
	else:
		if received_knockback != Vector2.ZERO:
			received_knockback = received_knockback.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * delta)
			velocity = received_knockback
			move_and_slide()
			
	handle_attack(last_held_direction)
	handle_block()
	
func handle_movement(delta: float, direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_held_direction = direction
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		
	if received_knockback != Vector2.ZERO:
		received_knockback = received_knockback.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * delta)
	elif not can_act:
#		ensure player can attack again after getting hit, and make sure sprite is visible again in case weirdness with timing here
		animation_player.play("RESET")
		movement_enabled = true
		can_act = true
		weapon.enabled = true
		
	velocity += received_knockback
	move_and_slide()

func handle_attack(direction: Vector2) -> void:
	var attack := Input.is_action_just_pressed("attack")
	if weapon != null and attack and can_act:	
		can_act = false	
		movement_enabled = false
		if direction.x > 0  + JOYSTICK_OFFSET:
			if direction.y > 0  + JOYSTICK_OFFSET:
				animation_player.play("attack_down_right")
				weapon.get_node('AnimationPlayer').play("attack_down_right")
			elif direction.y < 0 - JOYSTICK_OFFSET:
				animation_player.play("attack_up_right")
				weapon.get_node('AnimationPlayer').play("attack_up_right")
			else:
				animation_player.play("attack_right")
				weapon.get_node('AnimationPlayer').play("attack_right")
		elif direction.x < 0 - JOYSTICK_OFFSET:
			if direction.y > 0  + JOYSTICK_OFFSET:
				animation_player.play("attack_down_left")
				weapon.get_node('AnimationPlayer').play("attack_down_left")
			elif direction.y < 0 - JOYSTICK_OFFSET:
				animation_player.play("attack_up_left")
				weapon.get_node('AnimationPlayer').play("attack_up_left")
			else:
				animation_player.play("attack_left")
				weapon.get_node('AnimationPlayer').play("attack_left")
		else:
			if direction.y >= 0 :
				animation_player.play("attack_down")
				weapon.get_node('AnimationPlayer').play("attack_down")
			else:
				animation_player.play("attack_up")
				weapon.get_node('AnimationPlayer').play("attack_up")
				
		weapon.attack(self)

func handle_block() -> void:
	var block := Input.is_action_just_pressed("block")
	if block and can_act:
		movement_enabled = false
		is_blocking = true
		animation_player.play('blocking (no shield)')
		
	var release_block := Input.is_action_just_released("block")
	if release_block:
		movement_enabled = true
		is_blocking = false
		animation_player.play("RESET")

func set_attack_delay(attack_delay: float):
	for animation in animation_player.get_animation_list():
		if animation.contains('attack'):
			animation_player.get_animation(animation).length = animation_player.get_animation(animation).length + attack_delay

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name.contains("attack"):
		movement_enabled = true
		can_act = true
		weapon.enabled = true
		
	if anim_name.contains("hit"):
		movement_enabled = true
		can_act = true
		weapon.enabled = true
		
	if anim_name.contains("blocking (no shield)"):
		if Input.is_action_pressed("block"):
			movement_enabled = false
			animation_player.play("block (no shield)")
		else:
			movement_enabled = true
			animation_player.play("RESET")


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group('damage') and area.get_node('CollisionShape2D') != null and not area.get_node('CollisionShape2D').disabled:
		if 'damage' in area and 'knockback' in area:
			var damage = area.damage
			var hit_knockback = area.knockback
			if is_blocking:
				damage = damage * BLOCK_DAMAGE_NEGATION
				hit_knockback = hit_knockback * BLOCK_KNOCKBACK_NEGATION
				print('blocked')
			else:
				audio_stream_player_2d.play()
			print('Attack did ', damage, ' damage')
			print('Attack has ', hit_knockback, ' knockback')
			health -= damage
			received_knockback = area.get_node('CollisionShape2D').global_position.direction_to(global_position) * hit_knockback
			if not is_blocking and received_knockback != Vector2.ZERO:
				can_act = false
				weapon.enabled = false
				animation_player.stop()
				animation_player.play('RESET')				
				animation_player.play('hit')
			if health <= 0:
				dead = true
				audio_stream_player_2d.stop()
				death_sound = load("res://Assets/Sounds/player_dead.wav") as AudioStream
				audio_stream_player_2d.stream = death_sound
				#audio_stream_player_2d.volume_db = audio_stream_player_2d.volume_db
				audio_stream_player_2d.play()
				animation_player.play('die')
