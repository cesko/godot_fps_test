class_name Grenade extends Item

@export var damage = 1.0
#@export var explosion_radius := 5.0
@export var explosion_delay := 3.0
@export var explosion_area : Area3D = null
@export var explosion_particle_effect : Node3D
@export var explosion_sfx : AudioStream

@onready var pre_explosion_meshes = [$MeshInstance3D]

var _post_explosion_delay := 2.0

var _armed = false

func _ready():
	if not explosion_area:
		print("Grenade requires Area 3D with the size of the explosion")

func arm():
	if _armed:
		return
	
	_armed = true	
	get_tree().create_timer(explosion_delay, false).timeout.connect(explode)
	
func explode():
	print("BOOM!")
	if explosion_particle_effect:
		explosion_particle_effect.emitting = true
		
	if explosion_sfx:
		EffectsManager.play_world_sfx(explosion_sfx, 0.0, global_position)

	for mesh in pre_explosion_meshes:
		mesh.hide()
		
	get_tree().create_timer(_post_explosion_delay, false).timeout.connect(queue_free)
	
	var objects_in_range = explosion_area.get_overlapping_bodies()
	for obj in objects_in_range:
		print("Explosion hit: " + str(obj))
		if obj.has_method("hit"):			
			var hit_info = HitInfo.new()
			hit_info.hit_value = damage
			obj.hit(hit_info)
		



