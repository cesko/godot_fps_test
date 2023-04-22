extends State

var jump_mean_interval_msec = 1500
var next_jump_time_msec

# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	pass


# Virtual function. Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	
	# Check state transitions
	if owner.target_in_range():
		state_machine.transition_to("Attacking")
		return

	if owner.is_on_floor():
		var current_location = owner.global_transform.origin
		var next_location = owner.nav_agent.get_next_path_position()
		var new_velocity = (next_location - current_location).normalized() * owner.moving_speed

		owner.velocity = new_velocity
		# owner.velocity = owner.velocity.move_toward(new_velocity, .15)
		
		if Time.get_ticks_msec() >= next_jump_time_msec: 
			next_jump_time_msec = Time.get_ticks_msec() + randfn(jump_mean_interval_msec, 0.2 * jump_mean_interval_msec)
			owner.velocity += Vector3.UP * randf_range(3, 5)
	pass


# Virtual function. Corresponds to the `_physics_process()` callback.
func physics_update(_delta: float) -> void:
	pass


# Virtual function. Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	next_jump_time_msec = Time.get_ticks_msec() + randfn(jump_mean_interval_msec, 0.2 * jump_mean_interval_msec)
	pass


# Virtual function. Called by the state machine before changing the active state. Use this function
# to clean up the state.
func exit() -> void:
	pass
