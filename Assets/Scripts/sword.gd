extends Weapon

@onready var collision_shape_2d: CollisionShape2D = $Effect/Slash/Area2D/CollisionShape2D
@onready var slash: Sprite2D = $Effect/Slash
@onready var effect: Node2D = $Effect

@export var knockback: float
@export var damage: float

var slash_global_position: Vector2
var slash_local_position: Vector2

var slash_global_rotation: float
var slash_local_rotation: float

var slash_location_set: bool = false

func _physics_process(delta: float) -> void:
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


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('enemies') and body is CharacterBody2D:
		hit_enemy(body as CharacterBody2D, knockback, damage)
