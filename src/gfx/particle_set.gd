class_name ParticleSet extends Node3D

@export var emitting = false : 
	get:
		return emitting
	set(value):
		emitting = value

var _emitting_last = false

var particles = []

@export var particle_types:Array[String] = ["GPUParticles3D"]

func _ready():
	for type in particle_types:
		particles.append_array( find_children("*", type) )
		
	if particles.is_empty():
		print("No Particles found for ParticleSet")

func _process(delta):
	if emitting and not _emitting_last:
		emit()
	
	else:
		for p in particles:
			emitting = emitting and p.emitting
	
	_emitting_last = emitting

func emit():
	for p in particles:
		p.show()
		p.restart()
		p.emitting = true
