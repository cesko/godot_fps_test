extends RigidBody3D

class_name Item

@export var impulse_multiplier:float = 10

func hit(hit_info:HitInfo):
	var impulse = impulse_multiplier * hit_info.hit_value * hit_info.hit_direction
	var local_position = hit_info.hit_position - global_position
	apply_impulse(impulse, local_position)
	
