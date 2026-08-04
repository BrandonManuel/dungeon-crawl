extends Resource
class_name ParticlePreset

@export var amount: int = 8
@export var lifetime: float = 0.6
@export var direction: Vector2 = Vector2.UP
@export var spread: float = 45.0
@export var initial_velocity_min: float = 50.0
@export var initial_velocity_max: float = 120.0
@export var gravity: Vector2 = Vector2(0, 400)
@export var scale_amount_min: float = 1.0
@export var scale_amount_max: float = 1.0
@export var color: Color = Color(0.6, 0, 0)
@export var explosiveness: float = 0.9
@export var one_shot: bool = true
