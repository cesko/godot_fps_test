class_name FiniteStateMachine 

var _n_states:int = 0
var _states := []		
var _transitions := []	
var _wildcard_transitions := []	
var _current_state:int = -2
var _manual_transition:bool = false

const WILDCARD := -1

var _transitioned = false

func logprint(s:String):
	# print(s)
	pass

func check_transitions():
	_transitioned = false
	
	if _current_state < 0:
		return
	
	if _manual_transition:
		_manual_transition = false
		_transitioned = true
		logprint("Manually transitioned to '" + str(_current_state) + "'")
		
	else: 
		var transition_candidates = []
		if not _transitions[_current_state].is_empty():
			transition_candidates = _transitions[_current_state]	
		if not _wildcard_transitions.is_empty():
			# Skip Wildcards that transition to the current state
			for t in _wildcard_transitions:
				if t.getTo() != _current_state:
					transition_candidates.append(t)
			
		if transition_candidates.is_empty():
			logprint("WARN: no transitions from current state (" + str(_current_state) + ")")
		
		# handle transitions
		logprint("Handle transitions from current state '" + str(_current_state) + "'")
		for t in transition_candidates:
			if t.check() == true:
				var next_state = t.getTo()
				logprint("Found transition to '" + str(next_state) + "'")
				if isValidState(next_state):
					_current_state = next_state
					_transitioned = true
					break
				else:
					logprint("ERR: next state '" + str(next_state) + "' does not exist!")
		
func execute():
	# execute state
	if _transitioned:
		logprint("Entering state '" + str(_current_state) + "'")
		_states[_current_state].enter()
	else:
		logprint("no transition")
		logprint("Update state '" + str(_current_state) + "'")
		_states[_current_state].update()
		
	
func newState() -> int:
	_states.append(FiniteState.new())
	_transitions.append([])
	logprint("added state no. " + str(_n_states))
	if _current_state < 0:
		_current_state = _n_states
		logprint("state no. " + str(_n_states) + " is now the initial state")
	_n_states += 1
	return _n_states-1

func getState(id:int) -> FiniteState:
	if isValidState(id):
		return _states[id]
	else:
		logprint ("ERROR: No state with id " + str(id) + " found")
		return null

func setCurrentState(id:int):
	if isValidState(id):
		_current_state = id
	else:
		logprint ("ERROR: No state with id " + str(id) + " found")

func newTransition(from:int, to:int, condition:Callable):
	logprint("add transition from state " + str(from) + " to " + str(to))
	
	if not isValidState(to):
		logprint ("ERROR: No state with id " + str(to) + " found")
		return

	if isValidState(from):
		_transitions[from].append(FiniteStateTransition.new(to, condition))
	elif from == WILDCARD:
		_wildcard_transitions.append(FiniteStateTransition.new(to, condition))
	else:
		logprint ("ERROR: No state with id " + str(from) + " found")
	
	
func manualTransition(to:int):
	_manual_transition = true
	_current_state = to
	
func isCurrentState(id:int):
	return _current_state == id

func isValidState(id:int):
	return id >= 0 and id < _n_states
