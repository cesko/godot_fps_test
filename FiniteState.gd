class_name FiniteState

var _on_update:Callable
var _on_entry:Callable

func logprint(str:String):
	pass # print(str)

func _init():
	pass

func setUpdateFunction (function:Callable):
	_on_update = function
	

func setEntryFunction (function:Callable):
	_on_entry = function
	
func hasEntryFunction() -> bool:
	if _on_entry.is_valid():
		return false
	else:
		return true

func hasUpdateFunction() -> bool:
	if _on_update.is_valid():
		return false
	else:
		return true

func update():
	if _on_update.is_valid(): 
		_on_update.call()
	else:
		logprint("on_update Function invalid!")
	
func enter():
	if _on_entry.is_valid(): 
		_on_entry.call()
	else:
		logprint("on_update Function invalid!")
	
