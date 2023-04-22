extends State

var stuck_since = null

# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	pass


# Virtual function. Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	
	# Check state transitions
	if owner.target_in_range():
		state_machine.transition_to("Attacking")
		return
	
	var current_location = owner.global_transform.origin
	var next_location = owner.nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * owner.moving_speed

	owner.velocity = owner.velocity.move_toward(new_velocity, .15)
	
	if owner.get_real_velocity().length_squared() <= 1.0:
		if !stuck_since:
			stuck_since = Time.get_ticks_msec()
			
		if Time.get_ticks_msec() - stuck_since >= 1000:
			print("Stuck!")
			# Stuck -> randomly
			if owner.is_on_floor():
				owner.velocity += 5 * Vector3.UP
				stuck_since = null
			
	else:
		stuck_since = null

	var look_at_position = current_location
	look_at_position.x += new_velocity.x
	look_at_position.z += new_velocity.z
	
	owner.look_at(look_at_position)

	pass


# Virtual function. Corresponds to the `_physics_process()` callback.
func physics_update(_delta: float) -> void:
	pass


# Virtual function. Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	owner.anim_player.play("Walk")
	pass


# Virtual function. Called by the state machine before changing the active state. Use this function
# to clean up the state.
func exit() -> void:
	pass
