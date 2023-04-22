extends Node3D

class_name ParticlePool

@export var pool_size:int = 3
@export var particle_scene:PackedScene

var _buffer = RingBuffer.new()  

func _init(pool_size_:int, particle_scene_:PackedScene):
	pool_size = pool_size_
	particle_scene = particle_scene_
	super()

func _ready():
	pass
#	if not decal_scene.can_instance():
#		push_error("Decal Scene cannot be instanced")

func emit(tf:Transform3D):
	if _buffer.size() < pool_size:
		var p = particle_scene.instantiate()
		if p is GPUParticles3D:
			_buffer.append(p)
			add_child(p)
	
	var particles = _buffer.get_next()
	if particles:
		particles.set_global_transform(tf)
		particles.show()
		
		particles.restart()
		particles.emitting = true
		
	else:
		print("Scene is not")
	
