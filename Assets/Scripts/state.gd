extends Node

class_name State

var state_name: String

signal Transitioned

func process(delta: float) -> void:
	print('printing from state process')
	
func physics_process(delta: float) -> void:
		print('printing from state physics_process')


func enter() -> void:
	print('printing from state enter')

	
func exit() -> void:
	print('printing from state exit')

	
