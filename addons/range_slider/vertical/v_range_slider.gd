## A vertical range slider.
##
## This control allows the user to select a range of values using two handles moving vertically.
@tool
@icon("VRangeSlider.svg")
class_name VRangeSlider
extends RangeSlider

const RANGE_SLIDER_DOWN = preload("uid://diu5pjc685lmf")
const RANGE_SLIDER_UP = preload("uid://ixe81eiob7mm")

func _get_minimum_size() -> Vector2:
	var start_handle_height: float = _get_start_handle_extent()
	var end_handle_height: float = _get_end_handle_extent()
	
	var min_height: float = start_handle_height + end_handle_height + 10.0
	
	var start_handle_width: float = 10.0
	if handle_start_icon:
		start_handle_width = handle_start_icon.get_width()
		
	var end_handle_width: float = 10.0
	if handle_end_icon:
		end_handle_width = handle_end_icon.get_width()
		
	var min_width: float = maxf(start_handle_width, end_handle_width)
	
	return Vector2(min_width, min_height)

func _get_handle_extent(icon: Texture2D) -> float:
	return icon.get_height()

func _get_ratio_for_pos(position: Vector2, should_clamp: bool = true) -> float:
	var start_handle_height: float = _get_start_handle_extent()
	var end_handle_height: float = _get_end_handle_extent()
	var start_y: float = size.y - start_handle_height
	var end_y: float = end_handle_height
	
	if start_y <= end_y:
		return 0.0
	
	var ratio: float = remap(position.y, start_y, end_y, 0.0, 1.0)
	
	if should_clamp:
		ratio = clampf(ratio, 0.0, 1.0)
	
	return ratio

func _get_start_handle_rect() -> Rect2:
	var start_handle_height: float = _get_start_handle_extent()
	var end_handle_height: float = _get_end_handle_extent()
	var slider_usable_height: float = size.y - (start_handle_height + end_handle_height)
	if slider_usable_height <= 0:
		return Rect2()
	
	var start_ratio: float = _get_ratio_from_value(value_range.x)
	var start_pixel_position: float = (size.y - start_handle_height) - (start_ratio * slider_usable_height)

	var handle_width: float = size.x
	if handle_start_icon:
		handle_width = handle_start_icon.get_width()

	var handle_x_position: float = (size.x - handle_width) / 2.0
	
	return Rect2(handle_x_position, start_pixel_position, handle_width, start_handle_height)

func _get_end_handle_rect() -> Rect2:
	var start_handle_height: float = _get_start_handle_extent()
	var end_handle_height: float = _get_end_handle_extent()
	var slider_usable_height: float = size.y - (start_handle_height + end_handle_height)
	if slider_usable_height <= 0:
		return Rect2()

	var end_ratio: float = _get_ratio_from_value(value_range.y)
	var end_pixel_position: float = (size.y - start_handle_height) - (end_ratio * slider_usable_height)

	var handle_width: float = size.x
	if handle_end_icon:
		handle_width = handle_end_icon.get_width()

	var handle_x_position: float = (size.x - handle_width) / 2.0
	
	var rect_pos_y: float = end_pixel_position - end_handle_height
	
	return Rect2(handle_x_position, rect_pos_y, handle_width, end_handle_height)

func _get_bar_rect() -> Rect2:
	var start_handle_rect: Rect2 = _get_start_handle_rect()
	var end_handle_rect: Rect2 = _get_end_handle_rect()

	if not start_handle_rect.has_area() or not end_handle_rect.has_area():
		return Rect2()

	var start_y: float = start_handle_rect.position.y
	var end_y: float = end_handle_rect.end.y

	var bar_start_y: float = minf(start_y, end_y)
	var bar_end_y: float = maxf(start_y, end_y)
	
	var bar_height: float = bar_end_y - bar_start_y
	
	var min_bar_height: float = 4.0
	if bar_height < min_bar_height:
		var height_difference: float = min_bar_height - bar_height
		var centered_bar_start_y: float = bar_start_y - height_difference / 2.0
		return Rect2(0, centered_bar_start_y, size.x, min_bar_height)

	return Rect2(0, bar_start_y, size.x, bar_height)

func _get_slider_bar_rect() -> Rect2:
	var start_handle_height: float = _get_start_handle_extent()
	var end_handle_height: float = _get_end_handle_extent()
	return Rect2(0.0, end_handle_height, size.x, size.y - (start_handle_height + end_handle_height))

func _draw_center_indicator(ratio: float) -> void:
	var start_handle_height: float = _get_start_handle_extent()
	var end_handle_height: float = _get_end_handle_extent()
	var slider_usable_height: float = size.y - (start_handle_height + end_handle_height)
	var bar_center_y: float = (size.y - start_handle_height) - (ratio * slider_usable_height)
	
	var bar_margin: float = 2.0
	var left_center_position: Vector2 = Vector2(bar_margin, bar_center_y)
	var right_center_position: Vector2 = Vector2(size.x - bar_margin, bar_center_y)
	
	var _color = center_indicator_color

	if not editable:
		_color = center_indicator_disabled_color

	var bar_rect: Rect2 = _get_bar_rect()
	if bar_center_y >= bar_rect.position.y and bar_center_y <= bar_rect.end.y:
		draw_line(left_center_position, right_center_position, _color, 2.0, false)

func _get_default_end_icon() -> Texture2D:
	return RANGE_SLIDER_UP

func _get_default_start_icon() -> Texture2D:
	return RANGE_SLIDER_DOWN

func _update_mouse_shape():
	var cursor_shape = Control.CURSOR_ARROW
	
	if _current_drag_mode == DragMode.START or _current_drag_mode == DragMode.END:
		cursor_shape = Control.CURSOR_VSIZE
	elif _current_drag_mode != DragMode.NONE:
		cursor_shape = Control.CURSOR_MOVE
	elif _current_hover_state == HoverState.START or _current_hover_state == HoverState.END:
		cursor_shape = Control.CURSOR_VSIZE
	elif _current_hover_state == HoverState.BAR:
		cursor_shape = Control.CURSOR_MOVE
		
	if mouse_default_cursor_shape != cursor_shape:
		mouse_default_cursor_shape = cursor_shape
