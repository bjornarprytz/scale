extends Node2D

@onready var left: Area2D = $LeftArm
@onready var right: Area2D = $RightArm
@onready var display: RichTextLabel = $Display/Result

var prev_left_sum : int
var prev_right_sum : int

func _physics_process(delta: float) -> void:
	var left_cubes = left.get_overlapping_bodies()
	var right_cubes = right.get_overlapping_bodies()

	compare_cubes(left_cubes, right_cubes)

func compare_cubes(left_cubes, right_cubes):
	
	var left_weight := 0
	var right_weight := 0
	
	for cube in _get_stack_of_cubes(left_cubes):
		left_weight += cube.kind.weight
		cube.sleeping = false
	
	for cube in _get_stack_of_cubes(right_cubes):
		right_weight += cube.kind.weight
		cube.sleeping = false
	
	if (prev_left_sum == left_weight and prev_right_sum == right_weight):
		return
		
	prev_left_sum = left_weight
	prev_right_sum = right_weight
	
	var tween = create_tween().set_parallel()
	
	if (left_weight == right_weight):
		display.text = "="
		
		tween.tween_property(left, "position:y", 0.0, 1.0)
		tween.tween_property(right, "position:y", 0.0, 1.0)
		tween.tween_property($Visual/LeftString, "size:y", 113.0, 1.0)
		tween.tween_property($Visual/RightString, "size:y", 113.0, 1.0)
	elif (left_weight > right_weight):
		display.text = ">"
		tween.tween_property(left, "position:y", 30.0, 1.0)
		tween.tween_property(right, "position:y", -30.0, 1.0)
		tween.tween_property($Visual/LeftString, "size:y", 143.0, 1.0)
		tween.tween_property($Visual/RightString, "size:y", 83.0, 1.0)
	else:
		display.text = "<"
		tween.tween_property(left, "position:y", -30.0, 1.0)
		tween.tween_property(right, "position:y", 30.0, 1.0)
		tween.tween_property($Visual/LeftString, "size:y", 83.0, 1.0)
		tween.tween_property($Visual/RightString, "size:y", 143.0, 1.0)

func _get_stack_of_cubes(cubes: Array) -> Array[ElementCube]:
	var full_cluster : Array[ElementCube] = []
	
	var q : Array[ElementCube] = []
	for thing in cubes:
		if (thing is ElementCube):
			q.push_back(thing)
	
	while !q.is_empty():
		var cube = q.pop_front()
		
		if (full_cluster.find(cube) != -1):
			continue
			
		full_cluster.push_back(cube)
		var n = cube.get_colliding_bodies()
		for c in n:
			if (c is ElementCube) and (full_cluster.find(c) == -1):
				q.push_back(c)
			
	return full_cluster
