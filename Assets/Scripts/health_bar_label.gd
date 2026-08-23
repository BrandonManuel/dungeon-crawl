extends Label

@onready var health_ui: Control = $".."

func _process(delta: float) -> void:
	text = '%.0f' % health_ui.actor.current_health
