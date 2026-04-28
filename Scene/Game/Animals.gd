extends Sprite2D

@export var cell_size: int = 16

var is_following_mouse: bool = true
var ai_timer: float = 0.0

@export var move_interval_min: float = 1.0
@export var move_interval_max: float = 3.0

func _ready():
	ai_timer = randf_range(move_interval_min, move_interval_max)

func _process(delta):
	if is_following_mouse:
		var mouse_pos = get_global_mouse_position()
		var snapped = snap_to_grid(mouse_pos)
		position = snapped
	else:
		# Sistem AI: Bergerak acak secara periodik 
		# TODO: Butuh di improve
		ai_timer -= delta
		if ai_timer <= 0:
			ai_timer = randf_range(move_interval_min, move_interval_max)
			move_randomly()

func move_randomly():
	var dirs = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
	var random_dir = dirs[randi() % dirs.size()]
	
	var new_pos = position + (random_dir * cell_size)
	
	var size = get_viewport_rect().size
	if new_pos.x >= 0 and new_pos.x < size.x and new_pos.y >= 0 and new_pos.y < size.y:
		position = new_pos


func snap_to_grid(pos: Vector2) -> Vector2:
	return Vector2(
		floor(pos.x / cell_size) * cell_size,
		floor(pos.y / cell_size) * cell_size
	)

func spawn_random_animal():
	region_enabled = true
	if texture:
		var cols = 5
		var rows = 3
		var rand_x = randi() % cols
		var rand_y = randi() % rows
		
		var offset_x = 1 + (rand_x * 18)
		var offset_y = 1 + (rand_y * 18)
		
		region_rect = Rect2(offset_x, offset_y, 16, 16)
