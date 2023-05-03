extends Resource

class_name Capacity

signal amount_changed(new_amount:int)

@export var amount : int = 0 :
	set(value):
		print("Amount Setter called")
		if max_capacity >= 0:
			amount = clampi(value, _min, max_capacity)
		else:
			amount = max(value, _min)
		amount_changed.emit(amount)
	get:
		# print("Amount Getter called")
		return amount
		
@export var max_capacity : int = -1

var _min : int = 0

func _init(_max_capacity = -1, _amount = 0):
	print("Init")
	self.max_capacity = _max_capacity
	self.amount = _amount

func enforce_limits():
	if max_capacity >= 0:
		amount = clampi(amount, _min, max_capacity)
	else:
		amount = max(amount, _min)

func increase( by:int ):
	amount += by
	enforce_limits()
	amount_changed.emit(amount)
	
func decrease(by:int):
	increase(-1 * by)
	
func is_full() -> bool:
	if amount == max_capacity:
		return true
	else:
		return false

	
	
