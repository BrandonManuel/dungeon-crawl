extends CharacterBody2D

@onready var hand: Marker2D = $Hand
@onready var animation_player: AnimationPlayer = $Visual/AnimationPlayer

var weapon: Weapon = null

const SPEED = 100.0

func _process(delta: float) -> void:
	var held = hand.get_children()
	if held.size() == 1:
		weapon = held.get(0)
		
	if not animation_player.is_playing():
		animation_player.play("idle")
	
func _physics_process(delta: float) -> void:
	handle_movement(delta)
	
func handle_movement(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		
	var attack := Input.is_action_just_pressed("attack")
	if weapon != null and attack and not (animation_player.is_playing() and animation_player.current_animation == "attack"):
		animation_player.play("attack")
		weapon.attack(self)
		
	
	move_and_slide()
