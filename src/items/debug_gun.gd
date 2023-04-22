extends Weapon

@onready var normal_vector = $HitEffects/NormalVector
@onready var direction_vector = $HitEffects/DicrectionVector

@export var can_hit:bool = true

func shoot():
	if ray_cast.is_colliding():
		var target = ray_cast.get_collider()
		print("hit " + str(target))
		var hit_info = HitInfo.new()
		hit_info.from_ray_cast(ray_cast)		
		# place normal arrow
		normal_vector.draw(hit_info.hit_position, hit_info.hit_position + hit_info.hit_normal)
		direction_vector.draw(hit_info.hit_position-hit_info.hit_direction, hit_info.hit_position)
		# hit objects
		if can_hit:
			hit_info.hit_type = HitInfo.DEFAULT
			hit_info.hit_value = damage
			
			if target.has_method("hit"):
				target.hit(hit_info)
			else:
				EffectsManager.world_hit(hit_info)
	else:
		print("No Hit")


