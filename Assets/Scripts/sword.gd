extends Weapon

@onready var collision_shape_2d: CollisionShape2D = $Effect/Slash/Area2D/CollisionShape2D
@onready var slash: Sprite2D = $Effect/Slash

@export var knockback: float

var is_attacking: bool = false
func _physics_process(delta: float) -> void:
	if slash.visible:
		collision_shape_2d.disabled = false
	else:
		collision_shape_2d.disabled = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('enemies') and body is CharacterBody2D:
		hit_enemy(body as CharacterBody2D, knockback)
