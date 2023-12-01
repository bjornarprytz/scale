extends Node2D
class_name Global

signal purge(kind: ElementCube.Kind)
signal correct_guess(kind: ElementCube.Kind)
signal game_over(won: bool)

var kinds : Array[ElementCube.Kind] = []
var correct_answers: Array[ElementCube.Kind] = []
var wrong_answers := 0
var exploded_cubes := 0

var possible_colors = [
	Color.MEDIUM_AQUAMARINE,
	Color.CORAL,
	Color.WEB_GREEN,
	Color.MEDIUM_VIOLET_RED,
	Color.MIDNIGHT_BLUE,
	Color.BLUE_VIOLET,
	Color.TEAL,
	Color.KHAKI
]

func reset():
	kinds = []
	correct_answers = []
	wrong_answers = 0
	exploded_cubes = 0
	
	var chosen_weights = []
	
	for c in possible_colors:
		var w = randi_range(1, 12)
		while (chosen_weights.find(w) != -1):
			w = randi_range(1, 12)
		
		chosen_weights.push_back(w)
		
		var kind = ElementCube.Kind.new()
		kind.color = c
		kind.weight = w
		kind.stability = randi_range(15, 30)
		kind.bounce = randf_range(0.0, 0.5)
		
		kinds.push_back(kind)
	
	print("Initiated ", kinds.size(), " kinds")

func submit_answer(kind: ElementCube.Kind, answer: int) -> bool:
	if (kind.weight == answer and correct_answers.find(kind) == -1):
		correct_answers.push_back(kind)
		correct_guess.emit(kind)
		if (correct_answers.size() == kinds.size()):
			game_over.emit(true)
		return true
	else:
		wrong_answers += 1
	
	return false
	
static func get_contrast(c : Color) -> Color:
	var red = c.r
	var green = c.g
	var blue = c.b
	var alpha = c.a
	
	# Convert red, green, and blue to relative luminance
	var relative_luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
	
	# Determine if the contrast color should be light or dark
	var contrast_color: Color
	if relative_luminance > 0.5:
		contrast_color = Color(0, 0, 0, alpha)
	else:
		contrast_color = Color(1, 1, 1, alpha)
	
	return contrast_color

