extends Node2D

onready var tile_map = $TileMap

var entity_tiles = {
	"player": preload("res://player.tscn"),
	"enemy": preload("res://enemy.tscn"),
}

func _ready() -> void:
	replace_tiles()


func replace_tiles() -> void:
	var tile_set = tile_map.tile_set
	for cell in tile_map.get_used_cells():
		var tile_id = tile_map.get_cellv(cell)
		var tile_name = tile_set.tile_get_name(tile_id)
		if entity_tiles.has(tile_name):
			var scene = entity_tiles[tile_name]
			var instance = scene.instance()

			tile_map.add_child(instance)
			instance.position = Vector2(cell.x * 10, cell.y * 10)

			tile_map.set_cellv(cell, 1)

