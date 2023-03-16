class_name FiniteStateTransition

# var _from:FiniteState # not really required
var _to:String
var _condition:Callable

#func _init(from:FiniteState, to:FiniteState, condition:Callable):
#	_from = from
#	_to = to
#	_condition = condition

func _init(to:String, condition:Callable):
	_to = to
	_condition = condition
	
func check() -> bool:
	if _condition.call():
		return true
	else:
		return false

func getTo() -> String:
	return _to
