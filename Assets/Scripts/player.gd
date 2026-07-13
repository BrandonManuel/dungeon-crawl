extends CharacterBody2D

@onready var hand: Marker2D = $Hand
@onready var animation_player: AnimationPlayer = $Visual/AnimationPlayer

var weapon: Weapon = null
var last_held_direction: Vector2

const SPEED = 100.0

var weapon_starting_position: Vector2
var weapon_starting_rotation: float
	
func _process(delta: float) -> void:
	var held = hand.get_children()
	if held.size() == 1:
		weapon = held.get(0)
		
	if not animation_player.is_playing():
		animation_player.play("idle")
	
func _physics_process(delta: float) -> void:
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
