extends Resource

class_name Attribute

signal attribute_changed(value:float)

@export var current : float
@export var maximum : float = 1.0

var minimum = 0.0

func set_value(new_value, ignore_limits=false):
	current = new_value
	if not ignore_limits:
		attribute_clamp()
	attribute_changed.emit(current)

func increase_value(delta, ignore_limits=false):
	current += delta
	if not ignore_limits:
		attribute_clamp()
	attribute_changed.emit(current)

func get_value():
	return current
	
func set_max():
	current = maximum
	attribute_changed.emit(current)
	
func get_percent():
	return current / (maximum - minimum)

func attribute_clamp():
	current = clamp(current, minimum, maximum)
