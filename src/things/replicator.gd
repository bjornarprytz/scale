class_name Replicator
extends Node2D

signal replicate(kind: ElementCube.Kind)

const interval := 1.5
var time_left = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	time_left = max(0.0, time_left - delta)
	
	if (time_left <= 0.0):
		var cubes = $ContentsDetector.get_overlapping_bodies()
		var candidates : Array[ElementCube]
		for c in cubes:
			if c is ElementCube:
				candidates.push_back(c)
		
		if (candidates.size() > 0):
			replicate.emit(candidates.pick_random().kind)
			time_left = interval
