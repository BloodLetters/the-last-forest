extends Sprite2D

@export var cell_size: int = 16

var is_following_mouse: bool = true
var ai_timer: float = 0.0

@export var move_interval_min: float = 1.0
@export var move_interval_max: float = 3.0

@export_category("Movement Animation")
@export var jump_height: float = 10.0
@export var jump_duration: float = 0.3
@export var jump_swing_angle: float = 20.0

var _is_moving: bool = false

func _ready():
	ai_timer = randf_range(move_interval_min, move_interval_max)

func _process(delta):
	if is_following_mouse:
		var mouse_pos = get_global_mouse_position()
		var snapped = snap_to_grid(mouse_pos)
		position = snapped
	else:
		# Sistem AI: Bergerak acak secara periodik
		# Butuh di improve
		if not _is_moving:
			ai_timer -= delta
			if ai_timer <= 0:
				ai_timer = randf_range(move_interval_min, move_interval_max)
				move_randomly()

func move_randomly():
	var dirs = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
	var random_dir = dirs[randi() % dirs.size()]

	var new_pos = position + (random_dir * cell_size)

	var grid_x = floor(new_pos.x / cell_size)
	var grid_y = floor(new_pos.y / cell_size)

	if grid_x >= 2 and grid_x <= 34 and grid_y >= 0 and grid_y <= 15:
		_animate_move(new_pos, random_dir.x)

func _animate_move(target_pos: Vector2, dir_x: float) -> void:
	_is_moving = true
	var target_rotation = 0.0
	if dir_x > 0:
		target_rotation = jump_swing_angle
		flip_h = false
	elif dir_x < 0:
		target_rotation = - jump_swing_angle
		flip_h = true
	else:
		target_rotation = jump_swing_angle if randf() > 0.5 else -jump_swing_angle

	var base_offset_y = offset.y

	var pos_tween = create_tween().set_parallel(true)
	pos_tween.tween_property(self , "position", target_pos, jump_duration)

	var jump_tween = create_tween()
	jump_tween.tween_property(self , "offset:y", base_offset_y - jump_height, jump_duration * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(self , "offset:y", base_offset_y, jump_duration * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	var rot_tween = create_tween()
	rot_tween.tween_property(self , "rotation_degrees", target_rotation, jump_duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	rot_tween.tween_property(self , "rotation_degrees", 0.0, jump_duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await get_tree().create_timer(jump_duration).timeout
	_is_moving = false


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
