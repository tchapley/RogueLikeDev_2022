tool
extends Area2D

class_name Entity

func move(target: Vector2) -> void:
	position += target * 10

