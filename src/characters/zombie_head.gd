extends Enemy

signal attack_player(damage:float)

@onready var nav_agent = $NavigationAgent3D
@onready var collision_shape = $CollisionShape3D
@onready var audio_player = $AudioStreamPool

@export var moving_speed:float = 3.0
@export var attack_range:float = 1.5
@export var attack_damage:float = 1.0

@export var base_color:Color = Color(100.0/255, 150.0/255, 50.0/255)

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var sfx_attack = preload("res://assets/audio/zombie_attack.mp3")

@onready var attack_range_squared = attack_range**2

func _ready():
	super()
	change_color(base_color)

func _process(delta):
	update_target_location()

func _physics_process(delta):
	super(delta)
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()
	
func update_target_location():
	if target:
		nav_agent.target_position = target.global_position

func hit(hit_info:HitInfo):
	print("Zombie was hit")
	change_health(-hit_info.hit_value)
	change_color(base_color* get_health_percent())
	EffectsManager.blood_splash_particles.emit(hit_info.normal_pointed_tf())
	
	# blood splashes
	var blood_explosion = preload("res://scenes/gfx/blood_explosion.tscn").instantiate()
	blood_explosion.global_transform = hit_info.normal_pointed_tf()
	GameManager.world.add_child(blood_explosion)

	if alive and health <= 0:
		alive = false
		_on_death()
		

func change_color(c:Color) -> void:
	# var meshes = find_children("*", "MeshInstance3D")
	var meshes =[$HeadMesh]
	for mesh in meshes:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = c
		mesh.set_material_override(mat)

func target_in_range() -> bool:
	return global_position.distance_squared_to(target.global_position) <= attack_range_squared

func attack():
	if target_in_range() and alive:
		var hit_info = HitInfo.new()
		hit_info.hit_value = attack_damage
		target.hit(hit_info)

func randomization():
	pass
	

func _on_death():
	print("Zombie died")
	$CollisionShape3D.queue_free()
	$ZombieStateMachine.transition_to("Dying")
	died.emit()
