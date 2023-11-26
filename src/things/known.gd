extends VBoxContainer

var my_kind

func _ready() -> void:
	$Button.button_down.connect(_click)

func _click():
	Autoload.purge.emit(my_kind)

func set_kind(kind: ElementCube.Kind):
	$H/ColorRect.color = kind.color
	$H/Known.text = "=" + str(kind.weight)
	my_kind = kind


