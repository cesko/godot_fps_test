extends Node

@export var max_number_of_particles := 3

var buffer = []
var index = 0

var Particles = preload("res://particles_bullet_impact_wall.tscn")

func _ready():
	for i in range(max_number_of_particles):
		var p = Particles.instantiate()
		add_child(p)
		buffer.append(p)
		

func addParticles(tf:Transform3D):
	print("add impact paticles")
#	buffer[index].global_transform = tf
	buffer[index].global_transform.origin = tf.origin
	buffer[index].restart()
	buffer[index].emitting = true
	index += 1
	if index >= max_number_of_particles:
		index = 0
	

