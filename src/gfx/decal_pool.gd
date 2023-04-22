extends Node3D

class_name DecalPool

@export var pool_size:int = 3
@export var decal_scene:PackedScene

var _buffer = RingBuffer.new()  

func _init(pool_size_:int = 3, decal_scene_:PackedScene = null):
	pool_size = pool_size_
	decal_scene = decal_scene_
	super()

func _ready():
	pass
#	if not decal_scene.can_instance():
#		push_error("Decal Scene cannot be instanced")

func add(tf:Transform3D):
	if _buffer.size() < pool_size:
		var d = decal_scene.instantiate()
		if d is Decal:
			_buffer.append(d)
			add_child(d)
	
	var decal = _buffer.get_next()
	if decal:
		decal.set_global_transform(tf)
		decal.show()
		
	else:
		print("decal invalid")
	
