extends Node2D

@export var cell_size: int = 16
@export var grid_color: Color = Color(1, 1, 1, 0.06)
@export var grid_width: float = 1.0

@export var dash_length: float = 4.0
@export var gap_length: float = 4.0

@export var num_animals_to_spawn: int = 20
@export var spawn_interval: float = 0.5

var _spawn_timer: float = 0.0
var _spawned_count: int = 0

func _ready():
	randomize()
	if has_node("Animals"):
		# Jadikan node utama sebagai template tersembunyi (tidak ikut cursor lagi)
		$Animals.visible = false
		$Animals.is_following_mouse = false

func _process(delta):
	if _spawned_count < num_animals_to_spawn and has_node("Animals"):
		_spawn_timer -= delta
		if _spawn_timer <= 0:
			_spawn_timer = spawn_interval
			spawn_one_animal()

func spawn_one_animal():
	var size = get_viewport_rect().size
	var max_col = int(size.x) / cell_size
	var max_row = int(size.y) / cell_size
	
	if max_col > 0 and max_row > 0:
		var new_animal = $Animals.duplicate()
		
		new_animal.visible = true # Tampilkan hasil duplikat
		new_animal.is_following_mouse = false
		
		new_animal.spawn_random_animal()
		
		var rx = randi_range(2, 34) * cell_size
		var ry = randi_range(0, 15) * cell_size
		new_animal.position = Vector2(rx, ry)
		
		add_child(new_animal)
		_spawned_count += 1

func _draw():
	var start_x = 2 * cell_size
	var end_x = 34 * cell_size
	var start_y = 0 * cell_size
	var end_y = 15 * cell_size

	for x in range(start_x, end_x + cell_size, cell_size):
		draw_my_dashed_line(Vector2(x, start_y), Vector2(x, end_y), grid_color, grid_width)

	for y in range(start_y, end_y + cell_size, cell_size):
		draw_my_dashed_line(Vector2(start_x, y), Vector2(end_x, y), grid_color, grid_width)


func draw_my_dashed_line(from: Vector2, to: Vector2, color: Color, width: float):
	var direction = (to - from).normalized()
	var distance = from.distance_to(to)
	var drawn = 0.0

	while drawn < distance:
		var start = from + direction * drawn
		var end = from + direction * min(drawn + dash_length, distance)
		
		draw_line(start, end, color, width)
		
		drawn += dash_length + gap_length
