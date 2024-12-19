extends Node

var player : Node2D

func _update_quest_text(text:String):
	player.quest_text.set_text(text)

func _get_quest_recap(text:String):
	var text_to_add : Label = Label.new()
	text_to_add.set_text(text)
	player.quest_recap_container.add_child(text_to_add)

func _set_quest_panel_visibility(new_state : bool):
	if new_state:
		player.quest_panel.show()
	else:
		player.quest_panel.hide()
