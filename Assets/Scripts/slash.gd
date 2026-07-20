extends Sprite2D

var is_frozen: bool = false
var freeze_location: Vector2

func _physics_process(delta: float) -> void:
	if is_frozen:
		global_position = freeze_location


func freeze(location: Vector2) -> void:
	is_frozen = true
	freeze_location = location
