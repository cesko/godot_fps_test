extends StaticBody3D

func hit(hit_info:HitInfo):
	var tf = global_transform
	tf.origin = hit_info.collision_point
	$BulletHoles.addBulletHole(tf)
	$BulletImpactParticles.addParticles(tf)
	print("Hit the wall!")
