extends RigidBody2D

var size

func make_room(pos: Vector2, _size: Vector2) -> void:
	position = pos
	size = _size
	var s = RectangleShape2D.new()
	s.extents = size
	s.custom_solver_bias = 0.75
	$CollisionShape2D.shape = s
