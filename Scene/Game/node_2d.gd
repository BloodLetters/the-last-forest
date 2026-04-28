extends Node2D

@export var cell_size: int = 16
@export var grid_color: Color = Color(1, 1, 1, 0.06)
@export var grid_width: float = 1.0

@export var dash_length: float = 4.0
@export var gap_length: float = 4.0

func _draw():
	var size = get_viewport_rect().size

	for x in range(0, size.x, cell_size):
		draw_my_dashed_line(Vector2(x, 0), Vector2(x, size.y), grid_color, grid_width)

	for y in range(0, size.y, cell_size):
		draw_my_dashed_line(Vector2(0, y), Vector2(size.x, y), grid_color, grid_width)


func draw_my_dashed_line(from: Vector2, to: Vector2, color: Color, width: float):
	var direction = (to - from).normalized()
	var distance = from.distance_to(to)
	var drawn = 0.0

	while drawn < distance:
		var start = from + direction * drawn
		var end = from + direction * min(drawn + dash_length, distance)
		
		draw_line(start, end, color, width)
		
		drawn += dash_length + gap_length
