extends Enemy

signal attack_player(damage:float)
signal spawn_head(Transform3D, initial_velocity:Vector3, color:Color)

@onready var nav_agent = $NavigationAgent3D
@onready var anim_player = $AnimationPlayer
@onready var collision_shape = $CollisionShape3D
@onready var audio_player = $AudioStreamPool

@export var moving_speed:float = 3.0
@export var attack_range:float = 1.5
@export var attack_delay_msec:int = 200
@export var attack_angle:float 
@export var attack_damage:float = 1.0

@export var base_color:Color = Color(100.0/255, 150.0/255, 50.0/255)

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var sfx_attack = preload("res://assets/audio/zombie_attack.mp3")
var sfx_spawn = preload("res://assets/audio/zombie_spawn.mp3")

@onready var attack_range_squared = attack_range**2

var critical_hit = false

var headless = false

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
	if hit_info.hit_value >= health_max:
		critical_hit = true
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
	var meshes =[$BodyBesh, $BodyBesh/HeadMesh, $BodyBesh/LeftArm, $BodyBesh/LeftArm2]
	for mesh in meshes:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = c
		mesh.set_material_override(mat)

func target_in_range() -> bool:
	return global_position.distance_squared_to(target.global_position) <= attack_range_squared

func attack():
	await get_tree().create_timer(0.001 * attack_delay_msec).timeout
	if target_in_range() and alive:
		var hit_info = HitInfo.new()
		hit_info.hit_value = attack_damage
		target.hit(hit_info)

func throw_head():
	velocity = Vector3.ZERO
	anim_player.play("ThrowHead")
	get_tree().create_timer(1.6).timeout.connect( throw_head_finishing )

func throw_head_finishing():
	if alive:
		set_headless()
		var head_tf = $BodyBesh/HeadMesh.global_transform
		spawn_head.emit(head_tf, 10 * (global_transform.basis * Vector3.FORWARD), base_color* get_health_percent())

func set_headless():
	headless = true
	$BodyBesh/HeadMesh/HeadHitbox.disable()

func set_headed():
	headless = false
	$BodyBesh/HeadMesh/HeadHitbox.enable()

func randomization():
	var random_factor = randf_range(1.05, 1.25) 
	$BodyBesh.scale_object_local( random_factor * Vector3.ONE )
	moving_speed += randf_range(-.5, .5)
	

func _on_death():
	if critical_hit == false and headless == false:
		var head_tf = $BodyBesh/HeadMesh.global_transform
		spawn_head.emit(head_tf, Vector3.ZERO, base_color* get_health_percent())	
	
	print("Zombie died")
	$CollisionShape3D.queue_free()
	$ZombieStateMachine.transition_to("Dying")
	died.emit()
