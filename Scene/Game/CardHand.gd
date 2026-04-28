extends Control

@export_category("Card Layout Settings")
@export var card_spacing: float = 60.0 # Jarak horizontal antar kartu (Kecilkan agar saling bertumpuk)
@export var animation_speed: float = 12.0 # Kecepatan animasi penyusunan kartu
@export var hover_y_offset: float = 5.0 # Seberapa tinggi kartu naik saat di-hover
@export var select_y_offset: float = 15.0 # Seberapa tinggi kartu naik saat di-select

var target_positions: Array[Vector2] = []
var _previous_child_count: int = 0
var hovered_card = null
var selected_cards: Array = []

func _ready() -> void:
	update_hand_layout()

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

	for i in range(cards.size()):
		var card = cards[i]
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
				
			card.position = card.position.lerp(final_pos, delta * animation_speed)
			card.rotation_degrees = 0

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
		
	if selected_cards.has(card):
		selected_cards.erase(card)
	else:
		selected_cards.append(card)

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
