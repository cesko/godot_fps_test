extends Node

var bullet_holes = DecalPool.new(256, preload("res://scenes/gfx/decal_bullet_hole.tscn"))
var impact_particles = ParticlePool.new(3, preload("res://scenes/gfx/particles_impact.tscn"))
var blood_splash_particles = ParticlePool.new(3, preload("res://scenes/gfx/particles_blood_splash02.tscn"))
var blood_splat_decals = DecalPool.new(512, preload("res://scenes/gfx/decal_blood_splat.tscn"))
func _ready():
	add_child(bullet_holes)
	add_child(impact_particles)
	add_child(blood_splash_particles)
	add_child(blood_splat_decals)

func add_generic_bullet_hole(tf:Transform3D):
	bullet_holes.add(tf)
	
func add_generic_impact_particles(tf:Transform3D):
	impact_particles.emit(tf)
	
func world_hit(hit_info:HitInfo):
	print("world hit")
	var tf = Transform3D()
	tf.origin = hit_info.hit_position
	if hit_info.hit_normal.is_equal_approx(Vector3.DOWN):
		print("hit ceiling")
		tf = tf.rotated_local(Vector3.RIGHT, deg_to_rad(180))
	elif not hit_info.hit_normal.is_equal_approx(Vector3.UP):
		tf = tf.looking_at(hit_info.hit_position + hit_info.hit_normal, Vector3.UP)
		tf = tf.rotated_local(Vector3.RIGHT, deg_to_rad(-90))
	else:
		print("hit floor")	
	add_generic_bullet_hole(tf)
	
	var reflect = -hit_info.hit_direction.reflect(hit_info.hit_normal)
	if reflect.is_equal_approx(Vector3.DOWN):
		tf.basis = Basis(Vector3.RIGHT, 0)
		pass
	elif reflect.is_equal_approx(Vector3.UP):
		tf.basis = Basis(Vector3.RIGHT, PI)
		pass
	else:
		tf = tf.looking_at(hit_info.hit_position + reflect, Vector3.UP)
		pass
	add_generic_impact_particles(tf)

