extends RefCounted

class_name HitInfo

enum {NO_HIT, DEFAULT}

var hit_value:float # e.g. damage, physical impact, etc
var hit_type:=DEFAULT
var hit_position:Vector3
var hit_direction:Vector3
var hit_normal:Vector3

func from_ray_cast(ray_cast:RayCast3D):
	if ray_cast.is_colliding():
		hit_position = ray_cast.get_collision_point()
		hit_direction = (ray_cast.global_transform.basis * ray_cast.target_position).normalized()
		hit_normal = ray_cast.get_collision_normal()
	else:
		hit_type = NO_HIT

func normal_pointed_tf(forward=Vector3.FORWARD, up=Vector3.UP) -> Transform3D:
	
	var tf = Transform3D()
	tf.origin = hit_position
	
	var rot_axis = forward.cross(hit_normal).normalized()
	
	if rot_axis != Vector3.ZERO:
		var angle = forward.angle_to(hit_normal)	
		#print("hit_normal="+str(hit_normal) + ", rot_axis=" + str(rot_axis) + ", angle=" + str(angle))
		tf = tf.rotated_local(rot_axis, angle)
	else:
		var dot_product = forward.normalized().dot(hit_normal.normalized())
		if dot_product != 1:
			rot_axis = up.cross(forward).normalized()
			tf = tf.rotated_local(rot_axis, PI)
	
	return tf
	
#	var tf = Transform3D()
#	tf.origin = hit_position
#
#	if hit_normal.is_equal_approx(up):
#		pass
#	elif hit_normal.is_equal_approx(-up):
#		tf = tf.rotated_local(Vector3.RIGHT, PI)
#		pass
#	else:
#		tf = tf.looking_at(hit_position + hit_normal, Vector3.UP)
#	return tf
