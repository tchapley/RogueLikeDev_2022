extends Node2D

var tile_size := 10
var num_rooms := 50
var min_size := 4
var max_size := 10
var hspread := 400
var cull := 0.4
var path # AStar Pathfinding Object
var entity_tiles := {
	"player": preload("res://player.tscn"),
	"enemy": preload("res://enemy.tscn"),
}

onready var tile_map = $TileMap
onready var room = preload("res://Room.tscn")
onready var map = $TileMap

func _ready() -> void:
	randomize()
	make_rooms()
#	replace_tiles()


func _draw() -> void:
	for room in $rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2),
			Color(32, 228, 0), false)
	if path:
		for pos in path.get_points():
			for connection in path.get_point_connections(pos):
				var point_pos = path.get_point_position(pos)
				var conn_pos = path.get_point_position(connection)
				draw_line(point_pos, conn_pos, Color(1, 1, 0), 15, true)


func _process(_delta: float) -> void:
	update()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_select'):
		for room in $rooms.get_children():
			room.queue_free()
		make_rooms()
		path = null

	if event.is_action_pressed('ui_focus_next'):
		make_map()


func make_rooms():
	for i in range(num_rooms):
		var pos = Vector2(rand_range(-hspread, hspread), 0)
		var r = room.instance()
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		r.make_room(pos, Vector2(w, h) * tile_size)
		$rooms.add_child(r)
	yield(get_tree().create_timer(1.1), 'timeout')
	var room_positions := []
	for room in $rooms.get_children():
		if randf() < cull:
			room.queue_free()
		else:
			room_positions.append(room.position)
			room.mode = RigidBody2D.MODE_STATIC
	yield(get_tree(), 'idle_frame')
	path = find_mst(room_positions)


func find_mst(nodes):
	var path = AStar2D.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())

	while nodes:
		var min_dist = INF
		var min_pos = null
		var pos = null
		for point in path.get_points():
			point = path.get_point_position(point)
			for point_two in nodes:
				if point.distance_to(point_two) < min_dist:
					min_dist = point.distance_to(point_two)
					min_pos = point_two
					pos = point
		var id = path.get_available_point_id()
		path.add_point(id, min_pos)
		path.connect_points(path.get_closest_point(pos), id)
		nodes.erase(min_pos)
	return path


func make_map() -> void:
	map.clear()

	var full_rect = Rect2()
	for room in $rooms.get_children():
		var r = Rect2(room.position - room.size, room.get_node("CollisionShape2D").shape.extents * 2)
		full_rect = full_rect.merge(r)

	full_rect = full_rect.grow(10)

	var topleft = map.world_to_map(full_rect.position)
	var bottomright = map.world_to_map(full_rect.end)
	for x in range(topleft.x, bottomright.x):
		for y in range(topleft.y, bottomright.y):
			map.set_cell(x, y, 4)

	var corridors = []
	for room in $rooms.get_children():
		var s = (room.size / tile_size).floor()
		var pos = map.world_to_map(room.position)
		var ul = (room.position / tile_size).floor() - s
		for x in range(2, s.x * 2 - 1):
			for y in range(2, s.y * 2 - 1):
				map.set_cell(ul.x + x, ul.y + y, 0)

		var p = path.get_closest_point(room.position)
		for conn in path.get_point_connections(p):
			if not conn in corridors:
				var start = map.world_to_map(path.get_point_position(p))
				var end = map.world_to_map(path.get_point_position(conn))
				carve_path(start, end)
		corridors.append(p)


func carve_path(start, end):
	var x_diff = sign(end.x - start.x)
	var y_diff = sign(end.y - start.y)
	if x_diff == 0:
		x_diff = pow(-1.0, randi() % 2)
	if y_diff == 0:
		y_diff = pow(-1.0, randi() % 2)

	var x_y = start
	var y_x = end
	if randi() % 2 > 0:
		x_y = end
		y_x = start

	for x in range(start.x, end.x, x_diff):
		map.set_cell(x, x_y.y, 0)
		map.set_cell(x, x_y.y + y_diff, 0)
	for y in range(start.y, end.y, y_diff):
		map.set_cell(y_x.x, y, 0)
		map.set_cell(y_x.x + x_diff, y, 0)



#func replace_tiles() -> void:
#	var tile_set = tile_map.tile_set
#	for cell in tile_map.get_used_cells():
#		var tile_id = tile_map.get_cellv(cell)
#		var tile_name = tile_set.tile_get_name(tile_id)
#		if entity_tiles.has(tile_name):
#			var scene = entity_tiles[tile_name]
#			var instance = scene.instance()
#
#			tile_map.add_child(instance)
#			instance.position = Vector2(cell.x * 10, cell.y * 10)
#
#			tile_map.set_cellv(cell, 1)

