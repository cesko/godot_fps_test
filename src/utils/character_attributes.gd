extends Resource

class_name CharacterAttributes

@export var health:Attribute = Attribute.new()

func by_name(name:String) -> Attribute:
	if name=="health":
		return health
	else:
		return null


