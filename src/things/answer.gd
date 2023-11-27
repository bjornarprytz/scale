extends VBoxContainer


var my_kind : ElementCube.Kind

@onready var text_edit : TextEdit = $H/TextEdit
@onready var submit : Button = $H2/Submit
@onready var clear : Button = $H2/Clear

func _ready() -> void:
	clear.button_down.connect(_clear)
	submit.button_down.connect(_submit)
	text_edit.text_changed.connect(_guard_text)

func _clear():
	Autoload.purge.emit(my_kind)

func _submit():
	text_edit.editable = false
	submit.disabled = true

	if (my_kind.weight == int(text_edit.text)):
		submit.text = "Solved!"
	else:
		Autoload.purge.emit(my_kind)
		
		var tween = create_tween()
		tween.tween_method(_set_submit_text_countdown, 5.0, 0.0, 5.0)
		await tween.finished
		
		text_edit.editable = true
		submit.disabled = false
		submit.text = "Submit"

func _set_submit_text_countdown(t: float):
	submit.text = "%0.1f" % t

func _guard_text():
	var final_text = ""

	var regex = RegEx.new()
	regex.compile("[0-9]")

	var regex_match = regex.search_all(text_edit.text)
	if regex_match:
		for i in range(0,regex_match.size()):
			final_text += regex_match[i].get_string()

	if final_text.length() > 2:
		final_text = final_text.substr(0, 2)

	text_edit.text = final_text
	text_edit.set_caret_column(final_text.length())

func set_kind(kind: ElementCube.Kind):
	$H/ColorRect.color = kind.color
	my_kind = kind
