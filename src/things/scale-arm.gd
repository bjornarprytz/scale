extends Area2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var bodies = get_overlapping_bodies()
	
	if (bodies.size() > 0):
		$ColorRect.position.y = 3
	else:
		$ColorRect.position.y = -1
	
