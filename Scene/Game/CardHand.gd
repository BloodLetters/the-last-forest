extends Control

@export_category("Card Draw Settings")
@export var back_card_path: NodePath
@export var initial_draw_count: int = 5

var card_scenes: Array[PackedScene] = []

@export_category("Card Layout Settings")
@export var card_spacing: float = 60.0 # Jarak horizontal antar kartu (Kecilkan agar saling bertumpuk)
@export var animation_speed: float = 12.0 # Kecepatan animasi penyusunan kartu
@export var hover_y_offset: float = 5.0 # Seberapa tinggi kartu naik saat di-hover
@export var select_y_offset: float = 15.0 # Seberapa tinggi kartu naik saat di-select

var target_positions: Array[Vector2] = []
var _previous_child_count: int = 0
var hovered_card = null
var selected_cards: Array = []
var dragged_card = null
var _drag_start_mouse_pos: Vector2 = Vector2.ZERO
var _is_dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and dragged_card != null:
			if not _is_dragging:
				if selected_cards.has(dragged_card):
					selected_cards.erase(dragged_card)
				else:
					selected_cards.append(dragged_card)
			
			dragged_card = null
			_is_dragging = false

func _ready() -> void:
	_load_card_scenes()
	update_hand_layout()
	_draw_initial_cards()

func _process(delta: float) -> void:
	var cards = get_children()
	
	if cards.size() != _previous_child_count:
		_previous_child_count = cards.size()
		update_hand_layout()
		
		for card in cards:
			if card.has_signal("hovered") and not card.hovered.is_connected(_on_card_hovered):
				card.hovered.connect(_on_card_hovered)
				card.unhovered.connect(_on_card_unhovered)
			if card.has_signal("clicked") and not card.clicked.is_connected(_on_card_clicked):
				card.clicked.connect(_on_card_clicked)

	if dragged_card != null and not _is_dragging:
		if get_global_mouse_position().distance_to(_drag_start_mouse_pos) > 5.0:
			_is_dragging = true
			if selected_cards.has(dragged_card):
				selected_cards.erase(dragged_card)

	for i in range(cards.size()):
		var card = cards[i]
		
		# Logika Dragging & Animasi Swing
		if card == dragged_card and _is_dragging:
			var target_global_pos = get_global_mouse_position() + _drag_offset
			var diff_x = target_global_pos.x - card.global_position.x
			
			card.global_position = card.global_position.lerp(target_global_pos, delta * 25.0)
			
			# Swing animation saat didrag: kemiringan berlawanan arah gerakan
			var target_rotation = clamp(diff_x * 0.8, -45.0, 45.0)
			card.rotation_degrees = lerp(card.rotation_degrees, target_rotation, delta * 15.0)
			card.z_index = 10 # Paling depan saat ditarik
			continue
			
		if i < target_positions.size():
			var final_pos = target_positions[i]
			
			if selected_cards.has(card):
				final_pos.y -= select_y_offset
				card.z_index = 2
			elif card == hovered_card:
				final_pos.y -= hover_y_offset
				card.z_index = 1
			else:
				card.z_index = 0
				
			var dist_x = abs(card.position.x - final_pos.x)
			var current_target = final_pos
			
			if dist_x > 10.0:
				current_target.y -= dist_x * 0.4
				
			var move_speed = delta * animation_speed
			card.position = card.position.lerp(current_target, move_speed)
			
			card.rotation_degrees = lerp(card.rotation_degrees, 0.0, move_speed * 0.6)

var _hovered_areas: Array = []

func _on_card_hovered(card) -> void:
	if not _hovered_areas.has(card):
		_hovered_areas.append(card)
	_update_hovered_card()

func _on_card_unhovered(card) -> void:
	if _hovered_areas.has(card):
		_hovered_areas.erase(card)
		
	if hovered_card == card:
		hovered_card = null
		
	_update_hovered_card()

func _update_hovered_card() -> void:
	if hovered_card != null and _hovered_areas.has(hovered_card):
		return
		
	if _hovered_areas.size() > 0:
		hovered_card = _hovered_areas[0]

func _on_card_clicked(card) -> void:
	if card != hovered_card:
		return
		
	# Mulai persiapan drag / klik
	dragged_card = card
	_drag_start_mouse_pos = get_global_mouse_position()
	_drag_offset = card.global_position - _drag_start_mouse_pos
	_is_dragging = false

func update_hand_layout() -> void:
	var cards = get_children()
	var count = cards.size()
	
	target_positions.clear()
	
	if count == 0:
		return
		
	var center_index = (count - 1) / 2.0
	for i in range(count):
		var card = cards[i]
		var offset_from_center = i - center_index
		var card_center_offset = Vector2.ZERO
		if card is Control:
			card_center_offset = card.size / 2.0
			card.pivot_offset = card.size / 2.0
		
		var target_x = (offset_from_center * card_spacing) - card_center_offset.x
		
		var target_y = - card_center_offset.y * 2.0
		target_positions.append(Vector2(target_x, target_y))

func _load_card_scenes() -> void:
	var dir = DirAccess.open("res://Scene/Cards/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and (file_name.ends_with(".tscn") or file_name.ends_with(".tscn.remap")):
				var actual_file = file_name.replace(".remap", "")
				var scene = load("res://Scene/Cards/" + actual_file) as PackedScene
				if scene:
					card_scenes.append(scene)
			file_name = dir.get_next()

func _draw_initial_cards() -> void:
	# Tunggu sebentar agar seluruh node UI Container selesai menentukan posisi globalnya
	await get_tree().create_timer(0.1).timeout
	
	if card_scenes.is_empty():
		return
		
	var back_card = _get_back_card_node()
		
	for i in range(initial_draw_count):
		var card_scene = card_scenes.pick_random()
		if card_scene:
			var card_instance = card_scene.instantiate()
			add_child(card_instance)
			
			if back_card:
				card_instance.global_position = back_card.global_position
				card_instance.rotation_degrees = randf_range(-90.0, 90.0)
				card_instance.global_position.x += randf_range(-10.0, 10.0)
				card_instance.global_position.y += randf_range(-10.0, 10.0)
				
			await get_tree().create_timer(0.15).timeout

func _get_back_card_node() -> Control:
	if not back_card_path.is_empty():
		var node = get_node_or_null(back_card_path)
		if node is Control:
			return node
			
	var root = get_tree().current_scene
	if root:
		var node = root.find_child("BackCard", true, false)
		if node is Control:
			return node
			
	return null
