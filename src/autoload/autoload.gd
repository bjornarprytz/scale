extends Node2D
class_name Global

const MAX_WEIGHT = 12
const MIN_WEIGHT = 1
const PENALTY_CAP = 15.0

signal purge(kind: ElementCube.Kind)
signal correct_guess(kind: ElementCube.Kind)
signal game_over(won: bool)

var kinds : Array[ElementCube.Kind] = []
var unsolved_elements : Array[ElementCube.Kind] = []
var correct_answers: Array[ElementCube.Kind] = []
var wrong_answers := 0
var exploded_cubes := 0

var possible_colors = _generate_okabe_ito_palette()

func reset():
	kinds = []
	correct_answers = []
	unsolved_elements = []
	wrong_answers = 0
	exploded_cubes = 0
	
	var chosen_weights = []
	
	for c in possible_colors:
		var w = randi_range(MIN_WEIGHT, MAX_WEIGHT)
		while (chosen_weights.find(w) != -1):
			w = randi_range(MIN_WEIGHT, MAX_WEIGHT)
		
		chosen_weights.push_back(w)
		
		var kind = ElementCube.Kind.new()
		kind.color = c
		kind.weight = w
		kind.stability = randi_range(12, 25)
		kind.bounce = randf_range(0.0, 0.4)
		
		kinds.push_back(kind)
		unsolved_elements.push_back(kind)
	
	print("Initiated ", kinds.size(), " kinds")

func get_penalty():
	return min(float((Autoload.wrong_answers)) * 5.0, Autoload.PENALTY_CAP)

func submit_answer(kind: ElementCube.Kind, answer: int) -> bool:
	if (kind.weight == answer and correct_answers.find(kind) == -1):
		correct_answers.push_back(kind)
		correct_guess.emit(kind)
		if (correct_answers.size() == kinds.size()):
			game_over.emit(true)
		unsolved_elements.erase(kind)
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

static func _generate_okabe_ito_palette() -> Array[Color]:
	return [
		Color(0.1,0.1,0.1),
		Color(0.9, 0.6, 0),
		Color(0.35, 0.7, 0.9),
		Color(0, 0.6, 0.5),
		Color(0.95, 0.9, 0.25),
		Color(0, 0.45, 0.7),
		Color(0.8, 0.4, 0),
		Color(0.8, 0.6, 0.7)
	]
