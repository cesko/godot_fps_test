extends Node

class_name BloodEffectsPool

@export var max_particles = 3
var particles_buffer = []
var particles_index = 0
var Particle = preload("res://blood_splashing_particles.tscn")

@export var max_decals = 256
var decals_buffer = []
var decals_index = 0
var BloodSplatterDecal = preload("res://decal_blood_splatter.tscn")

var set_up = false

func _ready():
	initialize()
	
func initialize(): 
	set_up = true
	for i in range(max_particles):
		var p = Particle.instantiate()
		add_child(p)
		p.emitting = false
		particles_buffer.append(p)
	
	for i in range(max_decals):
		var d = BloodSplatterDecal.instantiate()
		add_child(d)
		d.set_visible(false)
		decals_buffer.append(d)


func addBloodSplatter(tf:Transform3D):
	if set_up == false:
		initialize()
	
#	tf = Transform3D(Vector3.RIGHT, Vector3.UP, Vector3.BACK, Vector3.ZERO)
	particles_buffer[particles_index].global_transform = tf
	particles_buffer[particles_index].restart()
	particles_buffer[particles_index].emitting = true
	print("blood splatter at " + str(tf))
	
	particles_index += 1
	if particles_index >= max_particles:
		particles_index = 0

func addBloodDecal(tf:Transform3D):
	if set_up == false:
		initialize()
		
	decals_buffer[decals_index].global_transform = tf
	decals_buffer[decals_index].set_visible(true)

	decals_index += 1
	if decals_index >= max_decals:
		decals_index = 0
