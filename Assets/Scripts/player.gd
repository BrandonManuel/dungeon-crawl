extends CharacterBody2D

@onready var hand: Marker2D = $Hand
@onready var animation_player: AnimationPlayer = $Visual/AnimationPlayer
@onready var pick_up_area: Area2D = $"Pick Up Area"

@export var attack_delay: float = 0.0

@onready var world_items: Node = $"../World Items"

var weapon: Weapon = null
var nearby_weapon: Weapon = null

var last_held_direction: Vector2

const SPEED = 100.0

var weapon_starting_position: Vector2
var weapon_starting_rotation: float

var movement_enabled: bool = true


func _ready() -> void:
	set_attack_delay(attack_delay)
	if weapon != null:
		disable_weapon_collision()
		
func _process(delta: float) -> void:
	if not animation_player.is_playing():
		animation_player.play("idle")
	
func _physics_process(delta: float) -> void:
	if not movement_enabled:
		return
		
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	handle_movement(delta, direction)
	handle_attack(last_held_direction)
	handle_drop_weapon()
	handle_pick_up_weapon()
	
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

func handle_drop_weapon() -> void:
	var drop_weapon := Input.is_action_just_pressed("drop_weapon")
	if drop_weapon and weapon != null and not (animation_player.is_playing() and animation_player.current_animation.contains("attack")):
		var weapon_pick_up_area: Area2D = weapon.get_node('Interactable Area')
		var weapon_pick_up_collision: CollisionShape2D = weapon_pick_up_area.get_node('CollisionShape2D')

		weapon.reparent(world_items)
		weapon_pick_up_collision.disabled = false

func handle_pick_up_weapon() -> void:
	var pick_up_weapon := Input.is_action_just_pressed("pick_up_weapon")
	if pick_up_weapon and nearby_weapon != null and weapon == null:
		if (nearby_weapon as Weapon).has_method('enable_outline'):
			nearby_weapon.enable_outline(false)
			
		nearby_weapon.reparent(hand)
		nearby_weapon.position = Vector2.ZERO
		nearby_weapon.rotation = 0.0
		
# pick up weapon
func _on_hand_child_entered_tree(node: Node) -> void:
	weapon = node
	disable_weapon_collision()

# drop weapon
func _on_hand_child_exiting_tree(node: Node) -> void:
	weapon = null

func _on_pick_up_area_area_entered(area: Area2D) -> void:
	if area.name == 'Interactable Area' and area.get_parent() is Weapon:
		var weapon = area.get_parent()
		if weapon.has_method('enable_outline'):
			weapon.enable_outline(true)
			
		nearby_weapon = weapon


func _on_pick_up_area_area_exited(area: Area2D) -> void:
	if area.name == 'Interactable Area' and area.get_parent() is Weapon:
		var weapon = area.get_parent()
		if weapon.has_method('enable_outline'):
			weapon.enable_outline(false)
			
		nearby_weapon = null

func disable_weapon_collision() -> void:
	var weapon_pick_up_area: Area2D = weapon.get_node('Interactable Area')
	var weapon_pick_up_collision: CollisionShape2D = weapon_pick_up_area.get_node('CollisionShape2D')
	weapon_pick_up_collision.disabled = true
