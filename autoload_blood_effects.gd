extends Node

var max_particles = 3
var particles_buffer = []
var particles_index = 0
var Particle = preload("res://blood_splashing_particles.tscn")

var max_decals = 256
var decals_buffer = []
var decals_index = 0

func _ready():
	for i in range(max_particles):
		var p = Particle.instantiate()
		add_child(p)
		p.emmitting = false
		particles_buffer.append(p)

func addBloodSplatter(tf:Transform3D):
	particles_buffer[particles_index].global_transform = tf
	particles_buffer[particles_index].restart()
	particles_buffer[particles_index].emitting = true
