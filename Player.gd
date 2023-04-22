extends CharacterBody3D

signal killed
signal environment_impact(Transform3D)

@onready var camera = $Camera3D
@onready var anim_player = $AnimationPlayer
@onready var muzzle_flash = $Camera3D/pistol/MuzzleFlash
@onready var aiming_raycast = $Camera3D/RayCast3D
@onready var audio_pistol_shot = $AudioPistolShot
@onready var audio_pistol_empty = $AudioPistolEmpty
@onready var audio_pistol_reload = $AudioPistolReload

const SPEED = 4.5
const SPRINT_SPEED = 6
const SPRINT_DURATION = 2.0
const SPRINT_JUMP_VELOCITY = 3
const JUMP_VELOCITY = 5
const ATTACK_DMG = 1

var _alive = true
var health_max:float = 5
var health:float = 5

var _ammu_max:int = 70
var _ammu_magsize:int = 7
var _ammu_gun:int = 7
var _ammu_reserve:int = 63

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

func _unhandled_input(event):
	
	if not _alive:
		return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if Input.is_action_just_pressed("shoot") and anim_player.current_animation != "shoot" and anim_player.current_animation != "reload" and not Input.is_action_pressed("sprint"):
		play_shoot_effects()
	
	if Input.is_action_just_pressed("reload") and anim_player.current_animation != "shoot":
		reload()
		

func _physics_process(delta):	
	
	if not _alive:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	var speed = SPEED
	var jump_speed = JUMP_VELOCITY
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
		jump_speed = SPRINT_JUMP_VELOCITY
	
		# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_speed

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	if anim_player.current_animation == "shoot" or  anim_player.current_animation == "reload":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		anim_player.play("move")
	else:
		anim_player.play("idle")

	move_and_slide()

func play_shoot_effects():
	if _ammu_gun == 0:
		audio_pistol_empty.play()
		return
	_ammu_gun -= 1
	if aiming_raycast.is_colliding() == false:
		print ("no hit :(")
	else:
		var target = aiming_raycast.get_collider()
		print ("hit " + target.get_parent().name + "/" + target.name + " (Class: " + target.get_class() + ")")
		if target.has_method("hit"):
			var hit_info = HitInfo.new()
			hit_info.damage = ATTACK_DMG
			hit_info.collision_point = aiming_raycast.get_collision_point()
			hit_info.collision_normal = aiming_raycast.get_collision_normal() 
			
			var q = get_quaternion()
			hit_info.collision_dir = aiming_raycast.target_position.rotated(q.get_axis().normalized(), q.get_angle())
			target.call("hit", hit_info)
		else:
			var tf = aiming_raycast.global_transform
			tf.origin = aiming_raycast.get_collision_point()
			environment_impact.emit(tf)
			
	
	anim_player.stop()
	anim_player.play("shoot")
	audio_pistol_shot.play()
	muzzle_flash.restart()
	muzzle_flash.emitting = true

func reload():
	if _ammu_gun == _ammu_magsize:
		return
	if _ammu_reserve <= 0:
		return
	else:
		var ammu_total = _ammu_gun + _ammu_reserve
		_ammu_gun = clamp(_ammu_magsize, 0, ammu_total)
		_ammu_reserve = ammu_total - _ammu_gun
		anim_player.stop()
		anim_player.play("reload")
		audio_pistol_reload.play()
	
func gethealth_percent() -> float:
	return health / health_max
	
func get_ammu_gun() -> int:
	return _ammu_gun
		
func get_ammu_reserve() -> int:
	return _ammu_reserve

func take_damage(damage:float):
	if not _alive:
		return
	health -= damage
	if health <= 0:
		_alive = false
		anim_player.stop()
		anim_player.play("dying")
		killed.emit()
