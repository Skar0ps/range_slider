## A horizontal range slider.
##
## This control allows the user to select a range of values using two handles moving horizontally.
@tool
@icon("HRangeSlider.svg")
class_name HRangeSlider
extends RangeSlider

func _get_minimum_size() -> Vector2:
	var start_handle_width: float = _get_start_handle_extent()
	var end_handle_width: float = _get_end_handle_extent()
	
	var min_width: float = start_handle_width + end_handle_width + 10.0
	
	var start_handle_height: float = 10.0
	if handle_start_icon:
		start_handle_height = handle_start_icon.get_height()
		
	var end_handle_height: float = 10.0
	if handle_end_icon:
		end_handle_height = handle_end_icon.get_height()
		
	var min_height: float = maxf(start_handle_height, end_handle_height)
	
	return Vector2(min_width, min_height)

func _get_handle_extent(icon: Texture2D) -> float:
	return icon.get_width()

func _get_ratio_for_pos(position: Vector2, should_clamp: bool = true) -> float:
	var start_handle_width: float = _get_start_handle_extent()
	var end_handle_width: float = _get_end_handle_extent()
	var start_x: float = start_handle_width
	var end_x: float = size.x - end_handle_width

	if start_x >= end_x:
		return 0.0

	var ratio: float = remap(position.x, start_x, end_x, 0.0, 1.0)

	if should_clamp:
		ratio = clampf(ratio, 0.0, 1.0)

	return ratio

func _get_start_handle_rect() -> Rect2:
	var start_handle_width: float = _get_start_handle_extent()
	var end_handle_width: float = _get_end_handle_extent()
	var slider_usable_width: float = size.x - (start_handle_width + end_handle_width)
	if slider_usable_width <= 0:
		return Rect2()

	var start_ratio: float = _get_ratio_from_value(value_range.x)
	var start_pixel_position: float = start_ratio * slider_usable_width + start_handle_width

	var handle_height: float = size.y
	if handle_start_icon:
		handle_height = handle_start_icon.get_height()

	var handle_y_position: float = (size.y - handle_height) / 2.0
	var rect_position_x: float = start_pixel_position - start_handle_width

	return Rect2(rect_position_x, handle_y_position, start_handle_width, handle_height)

func _get_end_handle_rect() -> Rect2:
	var start_handle_width: float = _get_start_handle_extent()
	var end_handle_width: float = _get_end_handle_extent()
	var slider_usable_width: float = size.x - (start_handle_width + end_handle_width)
	if slider_usable_width <= 0:
		return Rect2()

	var end_ratio: float = _get_ratio_from_value(value_range.y)
	var end_pixel_position: float = end_ratio * slider_usable_width + start_handle_width

	var handle_height: float = size.y
	if handle_end_icon:
		handle_height = handle_end_icon.get_height()

	var handle_y_position: float = (size.y - handle_height) / 2.0
	
	return Rect2(end_pixel_position, handle_y_position, end_handle_width, handle_height)

func _get_bar_rect() -> Rect2:
	var start_handle_rect: Rect2 = _get_start_handle_rect()
	var end_handle_rect: Rect2 = _get_end_handle_rect()

	if not start_handle_rect.has_area() or not end_handle_rect.has_area():
		return Rect2()

	var start_x: float = start_handle_rect.end.x
	var end_x: float = end_handle_rect.position.x

	var bar_start_x: float = minf(start_x, end_x)
	var bar_end_x: float = maxf(start_x, end_x)

	var bar_width: float = bar_end_x - bar_start_x

	var min_bar_width: float = 4.0
	if bar_width < min_bar_width:
		var width_difference: float = min_bar_width - bar_width
		var centered_bar_start_x: float = bar_start_x - width_difference / 2.0
		return Rect2(centered_bar_start_x, 0, min_bar_width, size.y)

	return Rect2(bar_start_x, 0, bar_width, size.y)

func _get_slider_bar_rect() -> Rect2:
	var start_handle_width: float = _get_start_handle_extent()
	var end_handle_width: float = _get_end_handle_extent()
	return Rect2(start_handle_width, 0.0, size.x - (start_handle_width + end_handle_width), size.y)

func _draw_center_indicator(ratio: float) -> void:
	var start_handle_width: float = _get_start_handle_extent()
	var end_handle_width: float = _get_end_handle_extent()
	var slider_usable_width: float = size.x - (start_handle_width + end_handle_width)
	var bar_center_x: float = ratio * slider_usable_width + start_handle_width
	
	var bar_margin: float = 2.0
	var top_center_position: Vector2 = Vector2(bar_center_x, bar_margin)
	var bottom_center_position: Vector2 = Vector2(bar_center_x, size.y - bar_margin)
	
	var _color = center_indicator_color

	if not editable:
		_color = center_indicator_disabled_color

	var bar_rect: Rect2 = _get_bar_rect()
	if bar_center_x >= bar_rect.position.x and bar_center_x <= bar_rect.end.x:
		draw_line(top_center_position, bottom_center_position, _color, 2.0, false)

func _update_mouse_shape():
	var cursor_shape = Control.CURSOR_ARROW
	
	if _current_drag_mode == DragMode.START or _current_drag_mode == DragMode.END:
		cursor_shape = Control.CURSOR_HSIZE
	elif _current_drag_mode != DragMode.NONE:
		cursor_shape = Control.CURSOR_MOVE
	elif _current_hover_state == HoverState.START or _current_hover_state == HoverState.END:
		cursor_shape = Control.CURSOR_HSIZE
	elif _current_hover_state == HoverState.BAR:
		cursor_shape = Control.CURSOR_MOVE
		
	if mouse_default_cursor_shape != cursor_shape:
		mouse_default_cursor_shape = cursor_shape
