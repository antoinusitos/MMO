@tool
extends RichTextLabel

func _ready():
	meta_clicked.connect(_on_meta_clicked)

func _on_meta_clicked(meta):
	OS.shell_open(str(meta))
