extends CharacterBody3D

signal killed

# Resources
var empty_weapon = preload("res://weapon.tscn")

# Parameter
@onready var camera = $Camera3D
@onready var weapon_hand = $Camera3D/WeaponHand
var current_weapon

@export var HEALTH_MAX :float = 5
@export var health :float = 5
@export var SPEED:float = 4.5
@export var SPRINT_SPEED:float = 6.5
@export var JUMP_SPEED:float = 5.0
@export var SPRINT_JUMP_SPEED:float = 3.0

# Inventory
@export var AMMU_CAPACITY:int = 70
@export var ammu_current:int = 70

var weapon_inventory = []


# Physics
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# internal
var _has_control:bool = true
var _alive:bool = true

func _ready():
	equip_weapon( empty_weapon.instantiate() )
	pass

func _unhandled_input(event):
	
	if not _has_control:
		return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if Input.is_action_just_pressed("shoot"):
		if current_weapon:
			current_weapon.shoot()
		
	
	if Input.is_action_just_pressed("reload"):
		if current_weapon:
			current_weapon.reload()
		

func _physics_process(delta):	
	
	if not _has_control:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	var speed = SPEED
	var jump_speed = JUMP_SPEED
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
		jump_speed = SPRINT_JUMP_SPEED
	
		# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
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
	
	if not is_on_floor():
		if current_weapon:
			current_weapon._move_state = Weapon.MoveState.JUMP
	elif input_dir != Vector2.ZERO:
		if current_weapon:
			current_weapon._move_state = Weapon.MoveState.WALK
	else:
		if current_weapon:
			current_weapon._move_state = Weapon.MoveState.IDLE

	move_and_slide()

func equip_weapon(weapon:Weapon):
	current_weapon = weapon
	weapon_hand.add_child(current_weapon)
	current_weapon.aiming_ray_cast.global_position = camera.global_position

func get_ammu_in_gun() -> int:
	if current_weapon:
		return current_weapon.magazin_current
	else:
		return -1
		
		
func take_damage(damage:float):
	if not _alive:
		return
	health -= damage
	if health <= 0:
		_alive = false
		# anim_player.stop()
		# anim_player.play("dying")
		killed.emit()
