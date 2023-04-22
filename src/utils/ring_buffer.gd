extends RefCounted

class_name RingBuffer

var index:int = -1
var buffer = []

func append(obj:Object):
	buffer.append(obj)

func get_next() -> Object:
	if buffer.size() == 0:
		return null
	
	index += 1
	if index >= buffer.size():
		index = 0
	return buffer[index]

func get_all() -> Array:
	return buffer

func size() -> int:
	return buffer.size()
