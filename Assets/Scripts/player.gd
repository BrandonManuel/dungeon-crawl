extends CharacterBody2D

@onready var hand: Marker2D = $Hand
@onready var animation_player: AnimationPlayer = $Visual/AnimationPlayer

@export var attack_delay: float = 0.0

var weapon: Weapon = null
var last_held_direction: Vector2

const SPEED = 100.0

var movement_enabled: bool = true

func _ready() -> void:
	var held = hand.get_children()
	if held.size() == 1:
		weapon = held.get(0)
		
	set_attack_delay(attack_delay)
		
func _process(delta: float) -> void:
	if not animation_player.is_playing():
		animation_player.play("idle")
	
func _physics_process(delta: float) -> void:
	if not movement_enabled:
		return
		
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	handle_movement(delta, direction)
	handle_attack(last_held_direction)
	
func handle_movement(delta: float, direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_held_direction = direction
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		
	
	move_and_slide()

func handle_attack(direction: Vector2) -> void:
	var attack := Input.is_action_just_pressed("attack")
	if weapon != null and attack and not (animation_player.is_playing() and animation_player.current_animation.contains("attack")):		
		movement_enabled = false
		if direction.x == 0:
			if direction.y >= 0:
				animation_player.play("attack_down")
			else:
				animation_player.play("attack_up")
		elif direction.x > 0:
			if direction.y == 0:
				animation_player.play("attack_right")
			elif direction.y > 0:
				animation_player.play("attack_down_right")
			else:
				animation_player.play("attack_up_right")
		else:
			if direction.y == 0:
				animation_player.play("attack_left")
			elif direction.y > 0:
				animation_player.play("attack_down_left")
			else:
				animation_player.play("attack_up_left")
				
		weapon.attack(self)

func set_attack_delay(attack_delay: float):
	for animation in animation_player.get_animation_list():
		if animation.contains('attack'):
			animation_player.get_animation(animation).length = animation_player.get_animation(animation).length + attack_delay

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name.contains("attack"):
		movement_enabled = true
