extends Node2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_info_2d_button_mouse_entered() -> void:
	$CardCanvas/UIControl/InfoButton.region_rect = Rect2(17.0, 4.0, 14.0, 9.0)
	$CardCanvas/UIControl/InfoButton/Label.position.y += 1
	print("masuk")

func _on_info_2d_button_mouse_exited() -> void:
	$CardCanvas/UIControl/InfoButton.region_rect = Rect2(1.0, 3.0, 14.0, 10.0)
	$CardCanvas/UIControl/InfoButton/Label.position.y -= 1


func _on_cast_2d_button_mouse_entered() -> void:
	$CardCanvas/UIControl/CastButton.region_rect = Rect2(17.0, 4.0, 14.0, 9.0)
	$CardCanvas/UIControl/CastButton/Label.position.y += 1

func _on_cast_2d_button_mouse_exited() -> void:
	$CardCanvas/UIControl/CastButton.region_rect = Rect2(1.0, 3.0, 14.0, 10.0)
	$CardCanvas/UIControl/CastButton/Label.position.y -= 1


func _on_redraw_2d_button_mouse_entered() -> void:
	$CardCanvas/UIControl/RedrawButton.region_rect = Rect2(17.0, 4.0, 14.0, 9.0)
	$CardCanvas/UIControl/RedrawButton/Label.position.y += 1

func _on_redraw_2d_button_mouse_exited() -> void:
	$CardCanvas/UIControl/RedrawButton.region_rect = Rect2(1.0, 3.0, 14.0, 10.0)
	$CardCanvas/UIControl/RedrawButton/Label.position.y -= 1
