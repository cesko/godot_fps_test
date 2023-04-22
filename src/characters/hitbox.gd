extends StaticBody3D

class_name HitBox

@export var damage_multiplier:float = 1.0

func hit(hit_info:HitInfo):
	hit_info.hit_value *= damage_multiplier
	owner.hit(hit_info)

func disable():
	collision_layer = 0
	
func enable():
	collision_layer = 128
