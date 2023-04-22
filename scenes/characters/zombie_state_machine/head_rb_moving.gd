extends State

var next_jump_msec;
var mean_time_between_jumps_msec = 2000;

# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	pass


# Virtual function. Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	
	# Check state transitions
#	if owner.target_in_range():
#		state_machine.transition_to("Attacking")
#		return

	var next_location = owner.nav_agent.get_next_path_position()
	var current_location = owner.global_transform.origin
	var current_direction = owner.get_linear_velocity().normalized()	
	var direction_to_target = next_location - current_location
	var force_direction = direction_to_target - (1 - direction_to_target.dot(current_direction)) * current_direction
	
	force_direction = force_direction.normalized()
	
	# little p velocity controller
	var vel_error = owner.moving_speed - owner.get_linear_velocity().length()
	var force = 30 * vel_error * force_direction
	
	var additional_force = Vector3.ZERO
	if (Time.get_ticks_msec() >= next_jump_msec):
		next_jump_msec = Time.get_ticks_msec() + randfn(mean_time_between_jumps_msec, 0.3 * mean_time_between_jumps_msec)
		additional_force += 20 * Vector3.UP
		print("Jump")

	owner.apply_force(force + additional_force)
	
	pass


# Virtual function. Corresponds to the `_physics_process()` callback.
func physics_update(_delta: float) -> void:
	pass


# Virtual function. Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	next_jump_msec = Time.get_ticks_msec() + randfn(mean_time_between_jumps_msec, 0.1 * mean_time_between_jumps_msec)
	pass


# Virtual function. Called by the state machine before changing the active state. Use this function
# to clean up the state.
func exit() -> void:
	pass
