extends Node2D

class_name Weapon

var player: CharacterBody2D

func attack(player: CharacterBody2D) -> void:
	self.player = player

func hit_enemy(enemy: CharacterBody2D, knockback) -> void:
	print(enemy, ' is hit')
	enemy.is_hit(player.position.direction_to(enemy.position) * knockback)
