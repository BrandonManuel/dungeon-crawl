extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_drag_vertical_enabled(true)
	set_drag_margin(SIDE_BOTTOM, .1)
	set_drag_margin(SIDE_TOP, .1)
	
	set_drag_horizontal_enabled(true)
	set_drag_margin(SIDE_LEFT, .1)
	set_drag_margin(SIDE_RIGHT, .1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.is_current()
