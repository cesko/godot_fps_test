class_name Zombie extends CharacterBody3D

signal attack_player(damage:float)

@onready var nav_agent = $NavigationAgent3D
@onready var anim_player = $AnimationPlayer
@onready var collision_shape = $CollisionShape3D

var SPEED = 3.0
var ATTACK_RANGE = 1.5
var DAMAGE = 1.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var health = 3.0
var health_max = 3.0

var fsm := FiniteStateMachine.new()

var alive = true

var base_color:Color = Color(100.0/255, 150.0/255, 50.0/255)

#States
var STATE_SPAWNING
var STATE_MOVING
var STATE_ATTACKING
var STATE_DYING
var STATE_TAKING_DAMAGE

func fsm_spawning_update():
	pass

func fsm_spawning_enter():
	pass

func fsm_spawning_transto_moving():
	return anim_player.current_animation != 'Spawn'
	
func fsm_moving_update():
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
	velocity = velocity.move_toward(new_velocity, .15)	
	
	var look_at_position = current_location
	look_at_position.x += new_velocity.x
	look_at_position.z += new_velocity.z
	look_at(look_at_position, Vector3.UP) #look in the direction of movement

	anim_player.play("Walk")

func fsm_moving_enter():
	pass
	
func fsm_moving_transto_attacking():
	return nav_agent.distance_to_target() <= ATTACK_RANGE	

func fsm_attacking_transto_moving():
	return anim_player.current_animation != 'Attack'

func fsm_attacking_update():
	pass

func fsm_attacking_enter():
	velocity = Vector3.ZERO
	attack()

func fsm_dying_update():
	if anim_player.current_animation != 'Dying':
		alive = false;
		
func fsm_dying_enter():
	velocity = Vector3.ZERO
	anim_player.play("Dying")
	collision_shape.disabled = true

	print("ded")
	#queue_free()
	pass
	
func fsm_all_transto_dying():
	return health <= 0
	
func fsm_taking_damage_update():
	pass

func fsm_taking_damage_enter():
	velocity = 0*velocity # Vector3.ZERO
	# anim_player.play("TakeDamage")
	pass

func fsm_taking_damage_transto_moving():
	#return anim_player.current_animation != 'TakeDamage'
	return true

func _ready():
	STATE_SPAWNING = fsm.newState()
	STATE_MOVING = fsm.newState()
	STATE_ATTACKING = fsm.newState()
	STATE_DYING = fsm.newState()
	STATE_TAKING_DAMAGE = fsm.newState()
	fsm.getState(STATE_MOVING).setUpdateFunction(fsm_moving_update)
	fsm.getState(STATE_ATTACKING).setEntryFunction(fsm_attacking_enter)
	fsm.getState(STATE_DYING).setEntryFunction(fsm_dying_enter)
	fsm.getState(STATE_DYING).setUpdateFunction(fsm_dying_update)
	fsm.getState(STATE_TAKING_DAMAGE).setEntryFunction(fsm_taking_damage_enter)
	
	fsm.newTransition(STATE_SPAWNING, STATE_MOVING, fsm_spawning_transto_moving)
	fsm.newTransition(STATE_MOVING, STATE_ATTACKING, fsm_moving_transto_attacking)
	fsm.newTransition(STATE_ATTACKING, STATE_MOVING, fsm_attacking_transto_moving)
	fsm.newTransition(FiniteStateMachine.WILDCARD, STATE_DYING, fsm_all_transto_dying)
	fsm.newTransition(STATE_TAKING_DAMAGE, STATE_MOVING, fsm_taking_damage_transto_moving)
	
	changeColor(base_color)

func _process(delta):
	fsm.check_transitions()

func _physics_process(delta):		
	fsm.execute()
	velocity.x = clamp(velocity.x, -1.5*SPEED, 1.5*SPEED)
	velocity.y = clamp(velocity.y, -1.5*SPEED, 1.5*SPEED)
	velocity.z = clamp(velocity.z, -1.5*SPEED, 1.5*SPEED)

	move_and_slide()
	
func update_target_location(target_location):
	nav_agent.target_position = target_location

func attack():
	anim_player.stop()
	anim_player.play("Attack")
	attack_player.emit(DAMAGE)
	

func take_damage(damage):
	health -= damage
	
	# print("hit! health=" + str(health))
	changeColor(base_color*health/health_max)
	fsm.manualTransition(STATE_TAKING_DAMAGE)
#	await anim_player.animation_finished 

func isAlive() -> bool:
	return alive

func getAllChildren(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = getAllChildren(child,arr)
	return arr

func changeColor(c:Color) -> void:
	var children = getAllChildren(self)
	for child in children:
		if child is MeshInstance3D:
			var mat = StandardMaterial3D.new()
			mat.albedo_color = c
			child.set_material_override(mat)
