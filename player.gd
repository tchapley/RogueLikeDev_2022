extends "res://entity.gd"

class_name Player

onready var ray = $RayCast2D

func _ready() -> void:
	ray.enabled = true

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		move(Vector2(0, -1))
	elif Input.is_action_just_pressed("ui_down"):
		move(Vector2(0, 1))
	elif Input.is_action_just_pressed("ui_left"):
		move(Vector2(-1, 0))
	elif Input.is_action_just_pressed("ui_right"):
		move(Vector2(1, 0))

func move(target: Vector2) -> void:
	var cast_to = target * 10
	ray.cast_to = cast_to
	ray.force_raycast_update()
	if !ray.is_colliding():
		.move(target)
