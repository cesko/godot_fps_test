extends State

var stuck_since = null

var next_throw_time_msec
var restore_head_time_msec

# Virtual function. Receives events from the `_unhandled_input()` callback.
func handle_input(_event: InputEvent) -> void:
	pass


# Virtual function. Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	
	# Check state transitions
	if owner.target_in_range():
		state_machine.transition_to("Attacking")
		return
	
	if owner.headless:
		if Time.get_ticks_msec() > restore_head_time_msec:
			owner.anim_player.play("RegrowHead")
			owner.set_headed()
			# owner.moving_speed = 3/2 * owner.moving_speed
			next_throw_time_msec = Time.get_ticks_msec() + randfn(10000, 1000)
	else:
		if Time.get_ticks_msec() > next_throw_time_msec :
			state_machine.transition_to("ThrowingHead")
	
	
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
	
	if current_location.is_equal_approx(look_at_position) == false and look_at_position - current_location != Vector3.UP:
		owner.look_at(look_at_position)

	pass


# Virtual function. Corresponds to the `_physics_process()` callback.
func physics_update(_delta: float) -> void:
	pass


# Virtual function. Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	owner.anim_player.play("Walk")
	if owner.headless:
		restore_head_time_msec = Time.get_ticks_msec() + 5000
	else:
		next_throw_time_msec = Time.get_ticks_msec() + randfn(10000, 1000)


# Virtual function. Called by the state machine before changing the active state. Use this function
# to clean up the state.
func exit() -> void:
	pass
