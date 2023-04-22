extends Control

class_name PushNotification

@export var label:Label

@export var print_duration:float = 5.0
@export var max_lines:int = 10

var _buffer = []
var _latest_index:int = -1
var _oldest_index:int = -1
var _stamps = []

func _ready():
	for i in range(max_lines):
		_stamps.append(0)
		_buffer.append("")

func _process(delta):
	# remove old lines from _buffer
	var now = Time.get_unix_time_from_system()
	var check_index = _latest_index
	for i in range(max_lines):
		if now - _stamps[check_index] > print_duration:
			_oldest_index = check_index+1
			break
		check_index -= 1
		if check_index < 0:
			check_index = _stamps.size()-1
	
	var temp_index = _oldest_index
	var msg = ""	
	while temp_index != _latest_index + 1:
		if temp_index >= _buffer.size():
			temp_index = 0
		msg += _buffer[temp_index] + "\n"
		temp_index += 1
	
	label.text = msg
	
func print(str:String) -> void: 
	print("push notification: " + str )
	_latest_index = _latest_index +1
	if _latest_index >= max_lines:
		_latest_index = 0
	_buffer[_latest_index] = str
	_stamps[_latest_index] = Time.get_unix_time_from_system()
	

