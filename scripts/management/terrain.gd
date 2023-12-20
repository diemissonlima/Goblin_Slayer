extends Node2D

const LAYER: int = 0
const FOAM: PackedScene = preload("res://scenes/management/foam.tscn")

@onready var grass_tilemap: TileMap = get_node("Grass")
@onready var water_tilemap: TileMap = get_node("Water")

# lista auxiliar que armazena a posicao dos tiles de grama no mundo
var grass_used_cells: Array
var water_used_cells: Array

func _ready() -> void:
	# retorna um retangulo com todos os tiles de grama usados
	var used_grass_rect: Rect2 = grass_tilemap.get_used_rect()
	grass_used_cells = grass_tilemap.get_used_cells(LAYER)
	generate_water_tiles(used_grass_rect) # funcao que gera os tiles de água
	generate_foam_tiles()


func generate_water_tiles(used_rect: Rect2) -> void:
	for x in range(used_rect.position.x - 10, used_rect.size.x + 10):
		for y in range(used_rect.position.y - 10, used_rect.size.y + 10):
			if grass_used_cells.has(Vector2i(x, y)):
				continue

			water_tilemap.set_cell(LAYER, Vector2i(x, y), LAYER, Vector2i(0, 0))

	water_used_cells = water_tilemap.get_used_cells(LAYER)


func generate_foam_tiles() -> void:
	for cell in grass_used_cells:
		if check_grass_neighbors(cell):
			spawn_foam(cell)


func check_grass_neighbors(cell: Vector2) -> bool:
	var left_neighbor: Vector2i = Vector2i(cell.x - 1, cell.y)
	var right_neighbor: Vector2i = Vector2i(cell.x + 1, cell.y)
	var up_neighbor: Vector2i = Vector2i(cell.x, cell.y - 1)
	var bottom_neighbor: Vector2i = Vector2i(cell.x, cell.y + 1)

	var neighbors_list: Array = [left_neighbor, right_neighbor, up_neighbor, bottom_neighbor]

	for neighbor in neighbors_list:
		if water_used_cells.has(neighbor):
			return true

	return false


func spawn_foam(foam_cell: Vector2) -> void:
	var foam = FOAM.instantiate()
	add_child(foam)

	foam.position = foam_cell * 64.0 + Vector2(32, 32)

