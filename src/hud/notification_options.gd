extends Resource

class_name NotificationOptions

enum AnimOptions {NONE, FADE}

@export var lifespan:float = 3.0

@export var out_anim:AnimOptions = AnimOptions.FADE
@export var out_duration:float = 1.0

func _init(lifespan_:float = 2.0, out_anim_:AnimOptions = AnimOptions.FADE, out_duration_:float = 1.0): 
	lifespan = lifespan_
	out_anim = out_anim_
	out_duration = out_duration_
