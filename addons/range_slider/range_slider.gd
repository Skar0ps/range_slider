## An abstract base class for range sliders with two handles.
##
## This class implements the core logic for a range slider, including value handling, drag interactions, and state management.
## It is not intended to be used directly. Instead, use [HRangeSlider] for horizontal sliders or [VRangeSlider] for vertical sliders.
## It extends the [Range] class and provides two handles to define the start and end bounds of the selected range.
@tool
@icon("RangeSlider.svg")
@abstract
class_name RangeSlider
extends Range

## Emitted when the range (the distance between the two handles) is changed.
signal range_changed(new_range: Vector2)

## Represents the hover state of the mouse over the control.
enum HoverState { 
	NONE, ## The mouse is not hovering over any part of the control.
	START, ## The mouse is hovering over the start value handle.
	END, ## The mouse is hovering over the end value handle.
	BAR ## The mouse is hovering over the bar representing the selected range.
}

## Represents the current dragging mode of the control.
enum DragMode { 
	NONE, ## The user is not dragging any part of the control.
	START, ## The user is dragging the start value handle.
	END, ## The user is dragging the end value handle.
	BAR, ## The user is dragging the bar, moving the entire range.
	EMPTY_AREA, ## The user initiated a drag on an empty area of the control.
	SCALE ## The user is scaling the range by holding the Shift key.
}

## The current range of the slider. The x component is the start value, and the y component is the end value.
@export var value_range: Vector2 = Vector2(25, 75):
	set(new_value):
		var new_clamped_value: Vector2 = new_value.clampf(min_value, max_value)
		if new_clamped_value.x > new_clamped_value.y:
			if new_clamped_value.x != value_range.x and new_clamped_value.y == value_range.y:
				new_clamped_value.y = new_clamped_value.x
			elif new_clamped_value.y != value_range.y and new_clamped_value.x == value_range.x:
				new_clamped_value.x = new_clamped_value.y
			else:
				new_clamped_value.y = new_clamped_value.x
		
		if value_range != new_clamped_value:
			value_range = new_clamped_value
			range_changed.emit(value_range)
			set_value_no_signal(value_range.x)
			queue_redraw()

## If [code]true[/code], the slider can be interacted with. If [code]false[/code], the slider is disabled and can only be modified by code.
@export var editable: bool = true :
	set(new_value):
		if editable != new_value:
			editable = new_value
			queue_redraw()
		if editable:
			set_mouse_filter(Control.MOUSE_FILTER_STOP)
		else:
			set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		

## If [code]true[/code], mouse wheel scroll will move the value range.
@export var scrollable: bool = true

## If [code]true[/code], the handles will always be visible. If [code]false[/code], the handles will only be visible when the mouse is interacting with the control.
@export var always_show_handles: bool = false :
	set(new_value):
		if always_show_handles != new_value:
			always_show_handles = new_value
			queue_redraw()

@export_group("Center Indicator")
## If true, a line will be drawn at the midpoint of the selected range.

@export_custom(PROPERTY_HINT_GROUP_ENABLE, "checkbox_only") var draw_center_indicator : bool = true:
	set(value):
		if draw_center_indicator != value:
			draw_center_indicator = value
			notify_property_list_changed()
			queue_redraw()

@export var center_indicator_color: Color = Color.WHITE :
	set(new_value):
		if not center_indicator_color.is_equal_approx(new_value):
			center_indicator_color = new_value
			queue_redraw()

@export var center_indicator_disabled_color: Color = Color.GRAY :
	set(new_value):
		if center_indicator_disabled_color != new_value:
			center_indicator_disabled_color = new_value
			queue_redraw()

@export_group("Visuals")


@export_subgroup("Colors")

## The normal color of the handles.
@export var handle_color: Color = Color.WHITE :
	set(new_value):
		if handle_color != new_value:
			handle_color = new_value
			queue_redraw()

## The color of the handles when the mouse is hovering over them.
@export var handle_hover_color: Color = Color.WHITE :
	set(new_value):
		if handle_hover_color != new_value:
			handle_hover_color = new_value
			queue_redraw()

## The color of the handles when they are pressed.
@export var handle_pressed_color: Color = Color.WHITE :
	set(new_value):
		if handle_pressed_color != new_value:
			handle_pressed_color = new_value
			queue_redraw()
	get:
		if Engine.is_editor_hint():
			return _get_accent_color()
		return handle_pressed_color

## The color of the handles when they are disabled.
@export var handle_disabled_color: Color = Color.GRAY :
	set(new_value):
		if handle_disabled_color != new_value:
			handle_disabled_color = new_value
			queue_redraw()

@export_subgroup("Icons")

## Icon for the start handle (Left for Horizontal, Bottom for Vertical). If not set, it defaults to the theme's icon.
@export var handle_start_icon: Texture2D:
	set(new_value):
		if handle_start_icon != new_value:
			handle_start_icon = new_value
			queue_redraw()
	get:
		if not handle_start_icon:
			return _get_default_start_icon()
		return handle_start_icon

## Icon when the start handle is hovered. If not set, it defaults to the normal start handle icon, or the theme's icon if no normal icon is set.
@export var handle_start_highlight_icon: Texture2D:
	set(new_value):
		if handle_start_highlight_icon != new_value:
			handle_start_highlight_icon = new_value
			queue_redraw()
	get:
		if not handle_start_highlight_icon:
			if not handle_start_icon:
				return _get_default_start_icon()
			return handle_start_icon
		return handle_start_highlight_icon

## Icon when the start handle is disabled. If not set, it defaults to the normal start handle icon, or the theme's icon if no normal icon is set.
@export var handle_start_disabled_icon: Texture2D:
	set(new_value):
		if handle_start_disabled_icon != new_value:
			handle_start_disabled_icon = new_value
			queue_redraw()
	get:
		if not handle_start_disabled_icon:
			if not handle_start_icon:
				return _get_default_start_icon()
			return handle_start_icon
		return handle_start_disabled_icon

## Icon for the end handle (Right for Horizontal, Top for Vertical). If not set, it defaults to the theme's icon.
@export var handle_end_icon: Texture2D:
	set(new_value):
		if handle_end_icon != new_value:
			handle_end_icon = new_value
			queue_redraw()
	get:
		if not handle_end_icon:
			return _get_default_end_icon()
		return handle_end_icon

## Icon when the handle is hovered. If not set, it defaults to the normal end handle icon, or the theme's icon if no normal icon is set.
@export var handle_end_highlight_icon: Texture2D:
	set(new_value):
		if handle_end_highlight_icon != new_value:
			handle_end_highlight_icon = new_value
			queue_redraw()
	get:
		if not handle_end_highlight_icon:
			if not handle_end_icon:
				return _get_default_end_icon()
			return handle_end_icon
		return handle_end_highlight_icon

## Icon when the handle is disabled. If not set, it defaults to the normal end handle icon, or the theme's icon if no normal icon is set.
@export var handle_end_disabled_icon: Texture2D:
	set(new_value):
		if handle_end_disabled_icon != new_value:
			handle_end_disabled_icon = new_value
			queue_redraw()
	get:
		if not handle_end_disabled_icon:
			if not handle_end_icon:
				return _get_default_end_icon()
			return handle_end_icon
		return handle_end_disabled_icon

@export_subgroup("StyleBoxes")
## The background of the slider. If not set, creates a StyleBoxFlat with only a border.
@export var slider_style: StyleBox:
	set(new_value):
		if slider_style != new_value:
			slider_style = new_value
			slider_style.changed.connect(queue_redraw)
			queue_redraw()
	get:
		if not slider_style:
			var style_box_flat: StyleBoxFlat = StyleBoxFlat.new()
			var base_color: Color = _get_base_color()
			var is_dark_theme: bool = base_color.get_luminance() < 0.5
			style_box_flat.draw_center = false
			style_box_flat.border_color = Color(0.3, 0.3, 0.3) if is_dark_theme else Color(0.7, 0.7, 0.7)
			style_box_flat.set_border_width_all(1)
			return style_box_flat
		return slider_style

## The background of the area representing the selected range.
@export var grabber_area_style: StyleBox:
	set(new_value):
		if grabber_area_style != new_value:
			grabber_area_style = new_value
			grabber_area_style.changed.connect(queue_redraw)
			queue_redraw()
	get:
		if not grabber_area_style:
			var style_box_flat: StyleBoxFlat = StyleBoxFlat.new()
			var base_color: Color = _get_base_color()
			var is_dark_theme: bool = base_color.get_luminance() < 0.5
			style_box_flat.bg_color = Color(0.5, 0.5, 0.5) if is_dark_theme else Color(0.8, 0.8, 0.8)
			return style_box_flat
		return grabber_area_style

## The background of the area representing the selected range when the mouse is hovering over it.
@export var grabber_area_hover_style: StyleBox:
	set(new_value):
		if grabber_area_hover_style != new_value:
			grabber_area_hover_style = new_value
			grabber_area_hover_style.changed.connect(queue_redraw)
			queue_redraw()
	get:
		if not grabber_area_hover_style:
			var style_box_flat: StyleBoxFlat = StyleBoxFlat.new()
			var base_color: Color = _get_base_color()
			var is_dark_theme: bool = base_color.get_luminance() < 0.5
			style_box_flat.bg_color = Color(0.8, 0.8, 0.8) if is_dark_theme else Color(0.6, 0.6, 0.6)
			return style_box_flat
		return grabber_area_hover_style

## The background of the area representing the selected range when it is being dragged or scaled.
@export var grabber_area_pressed_style: StyleBox:
	set(new_value):
		if grabber_area_pressed_style != new_value:
			grabber_area_pressed_style = new_value
			grabber_area_pressed_style.changed.connect(queue_redraw)
			queue_redraw()
	get:
		if not grabber_area_pressed_style:
			var style_box_flat: StyleBoxFlat = StyleBoxFlat.new()
			var base_color: Color = _get_base_color()
			var accent_color: Color =  _get_accent_color()
			var is_dark_theme: bool = base_color.get_luminance() < 0.5
			var hovered_color: Color = Color(0.8, 0.8, 0.8) if is_dark_theme else Color(0.6, 0.6, 0.6)
			style_box_flat.bg_color = hovered_color.lerp(accent_color, 0.8)
			return style_box_flat
		return grabber_area_pressed_style

## The background of the area representing the selected range.
@export var grabber_area_disabled_style: StyleBox:
	set(new_value):
		if grabber_area_disabled_style != new_value:
			grabber_area_disabled_style = new_value
			grabber_area_disabled_style.changed.connect(queue_redraw)
			queue_redraw()
	get:
		if not grabber_area_disabled_style:
			var style_box_flat: StyleBoxFlat = StyleBoxFlat.new()
			var base_color: Color = _get_base_color()
			var is_dark_theme: bool = base_color.get_luminance() < 0.5
			style_box_flat.bg_color = Color(0.3, 0.3, 0.3) if is_dark_theme else Color(0.85, 0.85, 0.85)
			return style_box_flat
		return grabber_area_disabled_style

## The offset used for dragging calculations.
var _drag_offset: float = 0.0

## The midpoint of the range when scaling.
var _drag_midpoint: float = 0.0

## The half-width of the range when scaling.
var _drag_half_width: float = 0.0

## The offset used for dragging calculations in ratio space.
var _drag_offset_ratio: float = 0.0

## The midpoint of the range when scaling in ratio space.
var _drag_midpoint_ratio: float = 0.0

## The half-width of the range when scaling in ratio space.
var _drag_half_width_ratio: float = 0.0

## The current hover state of the control.
var _current_hover_state: HoverState = HoverState.NONE

## A flag indicating if the mouse is inside the control's bounds.
var _mouse_inside: bool = false

## The current drag mode of the control.
var _current_drag_mode: DragMode = DragMode.NONE :
	set(new_value):
		if _current_drag_mode != new_value:
			_current_drag_mode = new_value
			queue_redraw()
			_update_mouse_shape()

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	changed.connect(func(): value_range = value_range; queue_redraw())

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_MOUSE_ENTER:
			_mouse_inside = true
			queue_redraw()
			_update_mouse_shape.call_deferred()
		NOTIFICATION_MOUSE_EXIT:
			_mouse_inside = false
			if _current_drag_mode == DragMode.NONE:
				_current_hover_state = HoverState.NONE
			queue_redraw()
			_update_mouse_shape()
		NOTIFICATION_FOCUS_ENTER,NOTIFICATION_FOCUS_EXIT:
			queue_redraw()

func _validate_property(property: Dictionary) -> void:
	if property.name.begins_with("center_indicator_") and not draw_center_indicator:
		property.usage = PROPERTY_USAGE_NO_EDITOR

#region Drawing the RangeSlider 

## Handles the drawing of the control.
func _draw() -> void:
	if max_value - min_value == 0:
		return
	
	_draw_slider_bar()
	_draw_range_bar()
	_draw_handles()
	if draw_center_indicator:
		_draw_center_line()

## Draws the background slider bar.
func _draw_slider_bar() -> void:
	var slider_bar_rect: Rect2 = _get_slider_bar_rect()
	var _slider_style: StyleBox = slider_style
	
	if _mouse_inside or _current_drag_mode != DragMode.NONE:
		var highlighted_style: StyleBox = slider_style.duplicate()
		highlighted_style.border_color = highlighted_style.border_color.lerp(grabber_area_hover_style.bg_color,0.3)
		_slider_style = highlighted_style
	
	if has_focus():
		var focus_style : StyleBox = slider_style.duplicate()
		focus_style.border_color = _get_accent_color()
		_slider_style = focus_style
	
	draw_style_box(_slider_style, slider_bar_rect)


## Draws the bar representing the selected range.
func _draw_range_bar() -> void:
	if value_range.x > value_range.y:
		return
	
	var bar_rect: Rect2 = _get_bar_rect()
	var current_grabber_area_style: StyleBox = grabber_area_style

	if _current_hover_state == HoverState.BAR:
		current_grabber_area_style = grabber_area_hover_style
	if _current_drag_mode == DragMode.BAR or _current_drag_mode == DragMode.SCALE or _current_drag_mode == DragMode.EMPTY_AREA:
		current_grabber_area_style = grabber_area_pressed_style

	if not editable:
		current_grabber_area_style = grabber_area_disabled_style

	if bar_rect.size.x > 0:
		draw_style_box(current_grabber_area_style, bar_rect)

## Draws the center indicator line.
func _draw_center_line() -> void:
	var center_ratio: float = 0.5
	
	if exp_edit and min_value > 0 and max_value > 0 and value_range.x > 0 and value_range.y > 0:
		var midpoint_value: float = sqrt(value_range.x * value_range.y)
		center_ratio = _get_ratio_from_value(midpoint_value)
	else:
		var start_ratio: float = _get_ratio_from_value(value_range.x)
		var end_ratio: float = _get_ratio_from_value(value_range.y)
		center_ratio = (start_ratio + end_ratio) / 2.0

	_draw_center_indicator(center_ratio)

## Draws the center indicator line.
func _draw_center_indicator(ratio: float) -> void: # Virtual
	pass

## Draws the start and end handles.
func _draw_handles() -> void:
	var no_mouse_interaction : bool = not _mouse_inside and _current_drag_mode == DragMode.NONE

	if no_mouse_interaction and not always_show_handles:
		return
	
	var start_handle_rect: Rect2 = _get_start_handle_rect()
	var end_handle_rect: Rect2 = _get_end_handle_rect()

	var start_icon: Texture2D = handle_start_icon
	var end_icon: Texture2D = handle_end_icon
	
	var start_icon_modulate: Color = handle_color
	
	if _current_hover_state == HoverState.START:
		start_icon_modulate = handle_hover_color
		start_icon = handle_start_highlight_icon
	if _current_drag_mode == DragMode.START:
		start_icon_modulate = handle_pressed_color
		start_icon = handle_start_icon

	var end_icon_modulate: Color = handle_color
	
	if _current_hover_state == HoverState.END:
		end_icon_modulate = handle_hover_color
		end_icon = handle_end_highlight_icon
	if _current_drag_mode == DragMode.END:
		end_icon_modulate = handle_pressed_color
		end_icon = handle_end_icon
	
	if not editable:
		start_icon_modulate = handle_disabled_color
		start_icon = handle_start_disabled_icon
		end_icon_modulate = handle_disabled_color
		end_icon = handle_end_disabled_icon
	
	if start_handle_rect.has_area():
		draw_texture(start_icon, start_handle_rect.position, start_icon_modulate)
	
	if end_handle_rect.has_area():
		draw_texture(end_icon, end_handle_rect.position, end_icon_modulate)

#endregion

#region Input Handling

## Processes input events for the control.
func _gui_input(event: InputEvent) -> void:
	if scrollable and has_focus():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_move_range_by_step(1)
			accept_event()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_move_range_by_step(-1)
			accept_event()
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)


## Handles mouse button events.
func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.pressed:
		if event.shift_pressed:
			_current_drag_mode = DragMode.SCALE
			if exp_edit and min_value > 0 :
				var start_ratio: float = _get_ratio_from_value(value_range.x)
				var end_ratio: float = _get_ratio_from_value(value_range.y)
				_drag_midpoint_ratio = (start_ratio + end_ratio) / 2.0
				_drag_half_width_ratio = (end_ratio - start_ratio) / 2.0
				_drag_offset_ratio = _get_ratio_for_pos(event.position)
			else:
				var value_at_click_position: float = _get_value_for_pos(event.position)
				_drag_midpoint = (value_range.x + value_range.y) / 2.0
				_drag_half_width = (value_range.y - value_range.x) / 2.0
				_drag_offset = value_at_click_position
		else:
			var value_at_click_position: float = _get_value_for_pos(event.position)
			var ratio_at_click_position: float = _get_ratio_for_pos(event.position)

			var start_handle_rect: Rect2 = _get_start_handle_rect()
			var end_handle_rect: Rect2 = _get_end_handle_rect()
			var bar_rect: Rect2 = _get_bar_rect()

			var is_on_start_handle: bool = start_handle_rect.has_point(event.position)
			var is_on_end_handle: bool = end_handle_rect.has_point(event.position)
			var is_on_bar: bool = bar_rect.has_point(event.position)

			if is_on_bar:
				_current_drag_mode = DragMode.BAR
			elif is_on_start_handle and is_on_end_handle:
				var dist_to_start: float = abs(value_at_click_position - value_range.x)
				var dist_to_end: float = abs(value_at_click_position - value_range.y)
				_current_drag_mode = DragMode.START if dist_to_start < dist_to_end else DragMode.END
			elif is_on_start_handle:
				_current_drag_mode = DragMode.START
			elif is_on_end_handle:
				_current_drag_mode = DragMode.END
			else:
				_current_drag_mode = DragMode.EMPTY_AREA
			
			if exp_edit and min_value > 0 and max_value > 0:
				if _current_drag_mode == DragMode.END:
					_drag_offset_ratio = ratio_at_click_position - _get_ratio_from_value(value_range.y)
				else: # start, bar, and empty area all drag relative to the start handle's value/ratio
					_drag_offset_ratio = ratio_at_click_position - _get_ratio_from_value(value_range.x)
			else:
				if _current_drag_mode == DragMode.END:
					_drag_offset = value_at_click_position - value_range.y
				else:
					_drag_offset = value_at_click_position - value_range.x
	else:
		_current_drag_mode = DragMode.NONE
		_update_hover_state(event.position)
		queue_redraw()


## Handles mouse motion events.
func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if _current_drag_mode == DragMode.NONE:
		_update_hover_state(event.position)
		return
	var new_range: Vector2 = value_range
	if exp_edit and min_value > 0 and max_value > 0:
		# Exponential mode: All calculations are done in the linear ratio space.
		var current_ratio: float = _get_ratio_for_pos(event.position, false)
		
		match _current_drag_mode:
			DragMode.SCALE:
				var ratio_difference: float = current_ratio - _drag_offset_ratio
				if _drag_offset_ratio < _drag_midpoint_ratio:
					ratio_difference = -ratio_difference
				elif _drag_offset_ratio == _drag_midpoint_ratio:
					ratio_difference = abs(ratio_difference)

				var new_half_width_ratio: float = maxf(0, _drag_half_width_ratio + ratio_difference)
				var new_start_ratio: float = _drag_midpoint_ratio - new_half_width_ratio
				var new_end_ratio: float = _drag_midpoint_ratio + new_half_width_ratio
				
				var start_value: float = _get_value_from_ratio(new_start_ratio)
				var end_value: float = _get_value_from_ratio(new_end_ratio)

				if event.is_command_or_control_pressed():
					new_range.x = roundf(start_value)
					new_range.y = roundf(end_value)
				else:
					new_range.x = snappedf(start_value, step)
					new_range.y = snappedf(end_value, step)

			DragMode.START:
				var desired_x_ratio: float = current_ratio - _drag_offset_ratio
				var value: float = _get_value_from_ratio(desired_x_ratio)
				if event.is_command_or_control_pressed():
					new_range.x = roundf(value)
				else:
					new_range.x = snappedf(value, step)
				if new_range.x > new_range.y:
					new_range.x = new_range.y
			
			DragMode.END:
				var desired_y_ratio: float = current_ratio - _drag_offset_ratio
				var value: float = _get_value_from_ratio(desired_y_ratio)
				if event.is_command_or_control_pressed():
					new_range.y = roundf(value)
				else:
					new_range.y = snappedf(value, step)
				if new_range.y < new_range.x:
					new_range.y = new_range.x

			DragMode.BAR, DragMode.EMPTY_AREA:
				var start_ratio: float = _get_ratio_from_value(value_range.x)
				var end_ratio: float = _get_ratio_from_value(value_range.y)
				var range_width_ratio: float = end_ratio - start_ratio

				var desired_x_ratio: float = current_ratio - _drag_offset_ratio
				var clamped_x_ratio: float = clampf(desired_x_ratio, 0.0, 1.0 - range_width_ratio)
				
				var snapped_x_value: float = snappedf(_get_value_from_ratio(clamped_x_ratio), step)
				var snapped_x_ratio: float = _get_ratio_from_value(snapped_x_value)
				
				# prevent snapping from pushing the range off the end
				if snapped_x_ratio + range_width_ratio > 1.0:
					snapped_x_ratio = 1.0 - range_width_ratio
				
				var start_value = _get_value_from_ratio(snapped_x_ratio)
				var end_value = _get_value_from_ratio(snapped_x_ratio + range_width_ratio)
				
				new_range.x = snappedf(start_value, step)
				new_range.y = snappedf(end_value, step)
		

	else:
		var new_value: float = _get_value_for_pos(event.position, false)
		
		match _current_drag_mode:
			DragMode.SCALE:
				var value_difference: float = new_value - _drag_offset
				if _drag_offset < _drag_midpoint:
					value_difference = -value_difference
				elif _drag_offset == _drag_midpoint:
					value_difference = abs(value_difference)
				var new_half_width: float = maxf(0, _drag_half_width + value_difference)
				
				var start_value: float = _drag_midpoint - new_half_width
				var end_value: float = _drag_midpoint + new_half_width

				if event.is_command_or_control_pressed():
					new_range.x = roundf(start_value)
					new_range.y = roundf(end_value)
				else:
					new_range.x = snappedf(start_value, step)
					new_range.y = snappedf(end_value, step)

			DragMode.START:
				var desired_x_value: float = new_value - _drag_offset
				if event.is_command_or_control_pressed():
					new_range.x = roundf(desired_x_value)
				else:
					new_range.x = snappedf(desired_x_value, step)
				if new_range.x > new_range.y:
					new_range.x = new_range.y
			
			DragMode.END:
				var desired_y_value: float = new_value - _drag_offset
				if event.is_command_or_control_pressed():
					new_range.y = roundf(desired_y_value)
				else:
					new_range.y = snappedf(desired_y_value, step)
				if new_range.y < new_range.x:
					new_range.y = new_range.x
			
			DragMode.BAR, DragMode.EMPTY_AREA:
				var current_range_width: float = value_range.y - value_range.x
				var desired_x_value: float = new_value - _drag_offset
				var target_x_value: float

				if event.is_command_or_control_pressed():
					target_x_value = roundf(desired_x_value)
				else:
					target_x_value = snappedf(desired_x_value, step)

				var max_x_value: float = max_value - current_range_width

				new_range.x = clampf(target_x_value, min_value, max_x_value)
				new_range.y = new_range.x + current_range_width
				
	value_range = new_range

## Moves the range by a step increment in the given direction.
func _move_range_by_step(direction: float) -> void:
	var increment: float = step if step > 0 else 1.0
	var offset: float = direction * increment
	
	var current_width: float = value_range.y - value_range.x
	var new_start: float = clampf(value_range.x + offset, min_value, max_value - current_width)
	var new_end: float = new_start + current_width
	
	if value_range.x != new_start or value_range.y != new_end:
		value_range = Vector2(new_start, new_end)

#endregion


## Updates the hover state based on the mouse position.
func _update_hover_state(position: Vector2) -> void:
	var new_hover_state: HoverState = HoverState.NONE
	var start_handle_rect: Rect2 = _get_start_handle_rect()
	var end_handle_rect: Rect2 = _get_end_handle_rect()
	var bar_rect: Rect2 = _get_bar_rect()

	if bar_rect.has_point(position):
		new_hover_state = HoverState.BAR
	elif start_handle_rect.has_point(position):
		new_hover_state = HoverState.START
	elif end_handle_rect.has_point(position):
		new_hover_state = HoverState.END
	
	if new_hover_state != _current_hover_state:
		_current_hover_state = new_hover_state
		queue_redraw()
		_update_mouse_shape()

## Changes the cursor shape depending on where it is on the RangeSlider.
func _update_mouse_shape():
	pass # Virtual

## Calculates the ratio corresponding to a given position on the slider.
func _get_ratio_for_pos(position: Vector2, should_clamp: bool = true) -> float:
	return 0.0 # Virtual method


## Calculates the value corresponding to a given position on the slider.
## The returned value is clamped between `min_value` and `max_value` if `should_clamp` is `true`.
func _get_value_for_pos(position: Vector2, should_clamp: bool = true) -> float:
	var ratio: float = _get_ratio_for_pos(position, should_clamp)
	return _get_value_from_ratio(ratio)


## Converts a value to its corresponding ratio (0.0 to 1.0).
## Applies a logarithmic conversion if [member exp_edit] is true.
func _get_ratio_from_value(value: float) -> float:
	if exp_edit and min_value > 0 and max_value > 0:
		if value <= min_value:
			return 0.0
		if value >= max_value:
			return 1.0
		return remap(log(value), log(min_value), log(max_value), 0.0, 1.0)
	else:
		return remap(value, min_value, max_value, 0.0, 1.0)


## Converts a ratio (0.0 to 1.0) to its corresponding value.
## Applies an exponential conversion if `exp_edit` is true.
func _get_value_from_ratio(ratio: float) -> float:
	if exp_edit and min_value > 0 and max_value > 0:
		return exp(remap(ratio, 0.0, 1.0, log(min_value), log(max_value)))
	else:
		return lerpf(min_value, max_value, ratio)


#region Rect calculations

## Calculates and returns the rectangle for the start value handle.
func _get_start_handle_rect() -> Rect2: # Virtual
	return Rect2()

## Calculates and returns the rectangle for the end value handle.
func _get_end_handle_rect() -> Rect2: # Virtual
	return Rect2()

## Calculates and returns the rectangle for the bar representing the selected range.
func _get_bar_rect() -> Rect2: # Virtual
	return Rect2()

## Calculates and returns the rectangle for the background slider bar.
func _get_slider_bar_rect() -> Rect2: # Virtual
	return Rect2()

#endregion

## Returns the extent (width for H, height for V) of the start handle.
func _get_start_handle_extent() -> float:
	if handle_start_icon:
		return _get_handle_extent(handle_start_icon)
	return 10.0

## Returns the extent (width for H, height for V) of the end handle.
func _get_end_handle_extent() -> float:
	if handle_end_icon:
		return _get_handle_extent(handle_end_icon)
	return 10.0

## Helper to get extent from icon based on orientation
func _get_handle_extent(icon: Texture2D) -> float: # Virtual
	return icon.get_width()

func _get_minimum_size() -> Vector2:
	return Vector2(16, 16) # Virtual

func _get_tooltip(at_position: Vector2) -> String:
	var hover_state: HoverState = _get_hover_state_for_pos(at_position)
	
	var value_text: String
	match hover_state:
		HoverState.START:
			value_text = "Range begin: " + _get_value_as_string(value_range.x)
		HoverState.END:
			value_text = "Range end: " + _get_value_as_string(value_range.y)
		HoverState.BAR:
			value_text = "Range: %s - %s" % [_get_value_as_string(value_range.x), _get_value_as_string(value_range.y)]
		_:
			value_text = "" 
	
	var tooltip: String = value_text
	var mod_key_name: String = "Cmd" if OS.get_name() == "macOS" else "Ctrl"
	var is_float_editing: bool = step == 0.0 or fmod(step, 1.0) > 1e-5
	
	if is_float_editing:
		tooltip += "\n\n" + (tr("Hold %s to round to integers.") % mod_key_name)
	
	tooltip += "\n" + tr("Hold Shift to scale around midpoint instead of moving.")
	
	return tooltip

## Returns the hover state for the given position.
func _get_hover_state_for_pos(position: Vector2) -> HoverState:
	var start_handle_rect: Rect2 = _get_start_handle_rect()
	var end_handle_rect: Rect2 = _get_end_handle_rect()
	var bar_rect: Rect2 = _get_bar_rect()

	if bar_rect.has_point(position):
		return HoverState.BAR
	elif start_handle_rect.has_point(position):
		return HoverState.START
	elif end_handle_rect.has_point(position):
		return HoverState.END
	return HoverState.NONE


## Returns a string representation of the given value.
func _get_value_as_string(value: float) -> String:
	# original code for determining integers in the cpp code
	# var is_integer_value: bool = fmod(step, 1.0) < 1e-5 and step != 0.0
	var is_integer_value: bool = roundi(step) == step
	if is_integer_value:
		return str(int(value))
	return str(snappedf(value, step))

## Returns the value range.
func get_value_range() -> Vector2:
	return value_range # Should not happen, but return a safe default.


## Returns the base color of the editor or a default dark color if not found.
func _get_base_color() -> Color:
	if has_theme_color("base_color","Editor"):
		return get_theme_color("base_color","Editor")
	return Color("#2c2b33")

## Returns the accent color of the editor, or the OS accent color if no accent color is found, or a default accent color if all else fails.
func _get_accent_color() -> Color:
	if has_theme_color("accent_color","Editor"):
		return get_theme_color("accent_color","Editor")
	var os_accent_color: Color = DisplayServer.get_accent_color()
	if os_accent_color != Color(0,0,0,0):
		return os_accent_color
	return Color("#699ce8")

## Returns the default icon for the start handle.
## Override this in subclasses to provide orientation-specific defaults.
func _get_default_start_icon() -> Texture2D:
	if Engine.is_editor_hint():
		return EditorInterface.get_editor_theme().get_icon("RangeSliderLeft", "EditorIcons")
	if has_theme_icon("RangeSliderLeft"):
		return get_theme_icon("RangeSliderLeft", "EditorIcons")
	return get_theme_icon("grabber", "HSlider")

## Returns the default icon for the end handle.
## Override this in subclasses to provide orientation-specific defaults.
func _get_default_end_icon() -> Texture2D:
	if Engine.is_editor_hint():
		return EditorInterface.get_editor_theme().get_icon("RangeSliderRight", "EditorIcons")
	if has_theme_icon("RangeSliderRight"):
		return get_theme_icon("RangeSliderRight", "EditorIcons")
	return get_theme_icon("grabber", "HSlider")
