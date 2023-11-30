extends RigidBody2D
class_name Shrapnel


# Behaviour:
# Lay to rest once it's been still on the ground for a little while

func _ready() -> void:
	var scale_factor = Vector2(randf_range(1.0, 3.0), randf_range(1.0, 3.0))
	$Shape.scale *= scale_factor
	$Color.scale *= scale_factor
	
