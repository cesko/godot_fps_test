extends Node3D

class_name AudioStreamPool

@export var pool_size:int = 3
@export var use_3d_audio:bool = true

var _buffer = RingBuffer.new()  

func _init(_pool_size:int=3, _use_3d_audio:bool=true):
	pool_size = _pool_size
	use_3d_audio = _use_3d_audio

func _ready():
	for i in range(pool_size):
		if use_3d_audio:
			_buffer.append(AudioStreamPlayer3D.new())
		else:
			_buffer.append(AudioStreamPlayer.new())
	
	for b in _buffer.get_all():
		add_child(b)

func play(audio:AudioStream, from_position:float=0.0, pos:=Vector3.ZERO):
	var stream = _buffer.get_next()
	if use_3d_audio:
		stream.global_position = pos
		pass
	stream.stream = audio
	stream.play(from_position)
