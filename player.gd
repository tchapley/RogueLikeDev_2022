extends Node2D


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		position += Vector2(0, -1) * 20
	elif Input.is_action_just_pressed("ui_down"):
		position += Vector2(0, 1) * 20
	elif Input.is_action_just_pressed("ui_left"):
		position += Vector2(-1, 0) * 20
	elif Input.is_action_just_pressed("ui_right"):
		position += Vector2(1, 0) * 20
