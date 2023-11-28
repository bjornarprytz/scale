extends Node

@onready var sensor : Area2D = $Sensor

func _physics_process(delta: float) -> void:
	var bodies = sensor.get_overlapping_bodies()
	
	for b in bodies:
		if (not (b is ElementCube)):
			continue
		var cube = b as RigidBody2D
		cube.linear_velocity = Vector2.RIGHT * 100.0
