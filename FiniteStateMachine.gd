class_name FiniteStateMachine 

var _states = {}		# Dict of state names (strings) to FiniteState objects 
var _transitions = {}	# Dict of state names to array of transitions 
var _current_state:String = ""
var _manual_transition = false

const WILDCARD = "*"

func logprint(str:String):
	pass # print(str)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process():
	if _current_state == "":
		return
	
	var transitioned = false
	
	if _manual_transition:
		_manual_transition = false
		transitioned = true
		logprint("Manually transitioned to '" + _current_state + "'")
		
	else: 
		var transition_candidates = []
		if _current_state in _transitions:
			transition_candidates = _transitions[_current_state]	
		if WILDCARD in _transitions:
			# Skip Wildcards that transition to the current state
			for t in _transitions[WILDCARD]:
				if t.getTo() != _current_state:
					transition_candidates.append(t)
			
		if transition_candidates.is_empty():
			logprint("WARN: no transitions from current state (" + _current_state + ")")
		
		# handle transitions
		logprint("Handle transitions from current state '" + _current_state + "'")
		for t in transition_candidates:
			if t.check() == true:
				var next_state = t.getTo()
				logprint("Found transition to '" + next_state + "'")
				if next_state in _states:
					_current_state = next_state
					transitioned = true
					break
				else:
					logprint("ERR: next state '" + next_state + "' does not exist!")
		

	# execute state
	if transitioned:
		logprint("Entering state '" + _current_state + "'")
		_states[_current_state].enter()
	else:
		logprint("no transition")
		logprint("Update state '" + _current_state + "'")
		_states[_current_state].update()
		
	
func newState(name:String):
	if name == WILDCARD:
		logprint("State name '" + name + "' invalid!")
		return
	
	if name not in _states:
		_states[name] = FiniteState.new()
		logprint("added state '" + name + "'")
		if _current_state == "":
			_current_state = name
			logprint("state '" + name + "' is now the initial state")
	else:
		logprint ("WARN: State with name '" + name + "' already exists.")

func getState(name:String) -> FiniteState:
	if name in _states:
		return _states[name]
	else:
		logprint ("ERROR: State with name '" + name + "' not found")
		return null

func setCurrentState(name:String):
	_current_state = name

func newTransition(from:String, to:String, condition:Callable):
	if to in [WILDCARD]:
		logprint("State name '" + to + "' invalid!")
		
	if from not in _transitions:
		_transitions[from] = Array()
	_transitions[from].append(FiniteStateTransition.new(to, condition))
	logprint("added transition from state '" + from + "' to '" + to + "'")
	
func manualTransition(to:String):
	_manual_transition = true
	_current_state = to
	
func isState(name:String):
	return _current_state == name
	
