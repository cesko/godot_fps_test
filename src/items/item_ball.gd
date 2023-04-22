extends Item

@onready var bullet_holes = $DecalBulletHoles

func hit(hit_info:HitInfo):
	var impulse = impulse_multiplier * hit_info.hit_value * hit_info.hit_direction
	var local_position = hit_info.hit_position - global_position
	apply_impulse(impulse, local_position)
	
	# GFX
	var tf := Transform3D()
	tf.origin = hit_info.hit_position
	if hit_info.hit_normal.is_equal_approx(Vector3.UP):
		tf.basis = Basis(Vector3.RIGHT, 0.0)
	elif hit_info.hit_normal.is_equal_approx(Vector3.DOWN):
		tf.basis = Basis(Vector3.RIGHT, PI)
	else:
		tf = tf.looking_at(hit_info.hit_position + hit_info.hit_normal)
		tf = tf.rotated_local(Vector3.RIGHT, PI/2)
	bullet_holes.add(tf)
