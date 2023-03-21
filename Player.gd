extends CharacterBody3D

signal killed

@onready var camera = $Camera3D
@onready var anim_player = $AnimationPlayer
@onready var muzzle_flash = $Camera3D/pistol/MuzzleFlash
@onready var aiming_raycast = $Camera3D/RayCast3D

const SPEED = 4.5
const JUMP_VELOCITY = 5
const ATTACK_DMG = 1

var _alive = truecur
var _health_max:float = 5
var _health:float = 5

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
	
	if Input.is_action_just_pressed("shoot") and anim_player.current_animation != "shoot" and anim_player.current_animation != "reload":
		play_shoot_effects()
	
	if Input.is_action_just_pressed("reload") and anim_player.current_animation != "shoot":
		reload()
		

func _physics_process(delta):	
	
	if not _alive:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if anim_player.current_animation == "shoot" or  anim_player.current_animation == "reload":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		anim_player.play("move")
	else:
		anim_player.play("idle")

	move_and_slide()

func play_shoot_effects():
	if _ammu_gun == 0:
		return
	_ammu_gun -= 1
	if aiming_raycast.is_colliding() == false:
		print ("no hit :(")
	else:
		var target = aiming_raycast.get_collider()
		print ("hit " + target.get_parent().name + "/" + target.name + " (Class: " + target.get_class() + ")")
		if target.has_method("take_damage"):
			target.call("take_damage", ATTACK_DMG)
	
	anim_player.stop()
	anim_player.play("shoot")
	muzzle_flash.restart()
	muzzle_flash.emitting = true

func reload():
	if _ammu_gun == _ammu_magsize:
		return
	else:
		var ammu_total = _ammu_gun + _ammu_reserve
		_ammu_gun = _ammu_magsize
		_ammu_reserve = ammu_total - _ammu_magsize
		anim_player.stop()
		anim_player.play("reload")
	
func get_health_percent() -> float:
	return _health / _health_max
	
func get_ammu_gun() -> int:
	return _ammu_gun
		
func get_ammu_reserve() -> int:
	return _ammu_reserve

func take_damage(damage:float):
	if not _alive:
		return
	_health -= damage
	if _health <= 0:
		_alive = false
		anim_player.stop()
		anim_player.play("dying")
		killed.emit()
