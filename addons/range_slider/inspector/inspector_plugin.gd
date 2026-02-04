@tool
extends EditorInspectorPlugin

const RANGE_SLIDER_PROPERTY_SCENE = preload("range_slider_property.gd")

func _can_handle(object: Object) -> bool:
	# don't override the original
	if object is ParticleProcessMaterial:
		return false
	return true

func _parse_property(object: Object, type: Variant.Type, property_name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if type == TYPE_VECTOR2 and hint_type == PROPERTY_HINT_RANGE:
		var range_hint_parts: PackedStringArray = hint_string.split(",")
		
		var minimum_value: float = 0.0
		var maximum_value: float = 100.0
		var step_value: float = 1.0
		var display_suffix: String = ""
		var should_hide_slider: bool = false
		var enable_exp_edit: bool = false
		var allow_manual_greater: bool = false
		var allow_manual_lesser: bool = false
		var convert_radians_to_degrees: bool = false
		var hide_control: bool = false

		if range_hint_parts.size() >= 2:
			minimum_value = range_hint_parts[0].to_float()
			maximum_value = range_hint_parts[1].to_float()
		
		# 2 because we skip the min and max values to go straight to the step value
		var current_part_index: int = 2
		if range_hint_parts.size() > 2 and range_hint_parts[2].is_valid_float():
			step_value = range_hint_parts[2].to_float()
			current_part_index = 3
		
		while current_part_index < range_hint_parts.size():
			var current_token: String = range_hint_parts[current_part_index].strip_edges()
			if current_token.begins_with("suffix:"):
				display_suffix = current_token.trim_prefix("suffix:")
			else:
				match current_token:
					"or_greater": allow_manual_greater = true
					"or_less": allow_manual_lesser = true
					"exp": enable_exp_edit = true
					"radians_as_degrees": convert_radians_to_degrees = true
					"degrees": display_suffix = "°"
					"hide_slider": should_hide_slider = true
					"hide_control": hide_control = true
			current_part_index += 1
		
		if should_hide_slider or hide_control:
			return false
		
		if convert_radians_to_degrees and display_suffix.is_empty():
			display_suffix = "°"
		
		var range_slider_editor: EditorProperty = RANGE_SLIDER_PROPERTY_SCENE.new()
		range_slider_editor.setup(minimum_value, maximum_value, step_value, enable_exp_edit, allow_manual_greater, allow_manual_lesser, should_hide_slider, display_suffix, convert_radians_to_degrees)
		add_property_editor(property_name, range_slider_editor)
		
		return true
	return false
