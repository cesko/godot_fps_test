extends Node3D

var number_of_directions = 10
var ray_length = 2.5

func _physics_process(delta):

	var space_state = get_world_3d().direct_space_state
	
	for i in range(number_of_directions):
		var pitch = randf_range(-PI/2, PI/2)
		var yaw = randf_range(-PI, PI)
		var length = ray_length
		
		var x = length * cos(pitch) * sin(yaw)
		var y = length * sin(pitch)
		var z = length * cos(pitch) * cos(yaw)
		
		var ray_orign = global_transform.origin
		var ray_target = ray_orign + Vector3(x, y, z)
		#var ray_target =  + 4*Vector3.DOWN
		
		var query = PhysicsRayQueryParameters3D.create(ray_orign, ray_target)
		query.collision_mask = 1
		# print("query " + str(query))
		var result = space_state.intersect_ray(query)
		# print("result " + str(result))
		if result.is_empty() == false:
			var hit_info = HitInfo.new()
			hit_info.hit_position = result.position
			hit_info.hit_normal = result.normal
			var decal_tf = hit_info.normal_pointed_tf(Vector3.UP, Vector3.RIGHT) #.rotated_local(Vector3.RIGHT, PI/2)
			EffectsManager.blood_splat_decals.add(decal_tf)

	queue_free()
