extends ProgressBar

@onready var health_ui: Control = $".."

func _process(delta: float) -> void:
	max_value = health_ui.actor.max_health
	value = health_ui.actor.current_health
