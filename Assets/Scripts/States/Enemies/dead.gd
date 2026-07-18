extends State

var enemy: Enemy

func _init() -> void:
	state_name = "dead"

func process(delta: float) -> void:
	return
	
func physics_process(delta: float) -> void:
	return
		
		
func enter() -> void:
	enemy.animated_sprite_2d.visible = false
	enemy.death_sprite.visible = true
	enemy.dead = true
	enemy.die(enemy.animation_player)
	
func exit() -> void:
	return
