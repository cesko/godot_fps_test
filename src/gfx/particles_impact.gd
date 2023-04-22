@tool
extends GPUParticles3D

class_name ParticlesImpact

@export var color:Color:
	set(new_color):
		color = new_color
		draw_pass_1.material.albedo_color = color



