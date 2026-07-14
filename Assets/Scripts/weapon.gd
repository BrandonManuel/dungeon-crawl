extends Node2D

class_name Weapon

var player: CharacterBody2D

func attack(attacker: CharacterBody2D) -> void:
	self.player = attacker

func hit_enemy(enemy: CharacterBody2D, knockback: float, damage: float) -> void:
	print(enemy, ' is hit')
	enemy.is_hit(player.position.direction_to(enemy.position) * knockback, damage)

func enable_outline(enabled: bool) -> void:
	material.set_shader_parameter("outline_enabled", enabled)
