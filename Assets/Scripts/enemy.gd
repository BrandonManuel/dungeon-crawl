extends CharacterBody2D

class_name Enemy

@export var KNOCKBACK_DECAY: float = 0.0
@export var SPEED = 10.0
@export var health: float = 20.0

var sprite_2d: Sprite2D
var animation_player: AnimationPlayer
var navigation_agent_2d: Node2DTrackingNavigationAgent2D

var hit: bool = false
var dead: bool = false
var attack_targets: Array[Player] = []
