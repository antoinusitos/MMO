extends Node

var player : Node2D

var db : Collection = Collection.new("res://Items/DB.tableCollection.res")

var current_quest_id : int = -1
var current_quest_text : Label = null

var quests = Array([], TYPE_DICTIONARY, "", null)

func _on_item_picked(item_id : int, item_number : int):
	if current_quest_id == -1:
		return
	elif quests.size() == 0:
		return
	
	for quest in quests:
		if quest["quest_item_needed"] == item_id:
			quest["quest_fill"] += item_number
			
	_update_current_quest()

func _update_current_quest():
	if current_quest_id == -1:
		current_quest_text.set_text("")
		return
		
	var quest = get_current_quest()
	current_quest_text.set_text(quest["quest_description"] + "\n" + "(" + str(quest["quest_fill"]) + "/" + str(quest["quest_objective"]) + ")")	

func _update_quest_text(text:String):
	player.quest_text.set_text(text)

func _get_quest_recap(text:String):
	current_quest_text = Label.new()
	current_quest_text.set_text(text)
	current_quest_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	player.quest_recap_container.add_child(current_quest_text)

func _set_quest_panel_visibility(new_state : bool):
	if new_state:
		player.quest_panel.show()
	else:
		player.quest_panel.hide()

func add_quest(quest_id : int):
	var all_quests_table : Datatable = db.get_table("quests")
	var all_quests : Array = all_quests_table.get_items_list()
	for quest in all_quests:
		if all_quests_table.get_item(quest).get("quest_id") == quest_id:
			quests.append(all_quests_table.get_item(quest))
			if current_quest_id == -1:
				var new_quest = all_quests_table.get_item(quest)
				current_quest_id = new_quest["quest_id"]
				var already_owned : int = player._get_item_number(new_quest["quest_item_needed"])
				_get_quest_recap(new_quest["quest_description"] + "\n" + "(" + str(already_owned) + "/" + str(new_quest["quest_objective"]) + ")")
				_update_quest_text(new_quest["quest_dialog"])

func get_quest(quest_id : int):
	var all_quests_table : Datatable = db.get_table("quests")
	var all_quests : Array = all_quests_table.get_items_list()
	for quest in all_quests:
		if all_quests_table.get_item(quest).get("quest_id") == quest_id:
			return all_quests_table.get_item(quest)
	return null

func _clean_current_quest():
	current_quest_id = -1
	_update_current_quest()

func show_all_quests():
	if not player.all_quest_container.visible:
		return
	
	if player.all_quest_container.get_child_count() > 0:
		for index in range(0, player.all_quest_container.get_child_count(), 1):
			player.all_quest_container.get_child(index).queue_free()
		
	var index : int = 0
	for quest in quests:
		var already_owned : int = player._get_item_number(quest["quest_item_needed"])
		var b : Button = Button.new()
		var active : String = ""
		if quest["quest_id"] == current_quest_id:
			active = "(Active)"
		b.set_text(active + quest["quest_name"] + " : " + quest["quest_description"] + "(" + str(already_owned) + "/" + str(quest["quest_objective"]) + ")")
		player.all_quest_container.add_child(b)
		b.connect("pressed", Callable(self, "set_current_quest").bind(quest["quest_id"]))
		index += 1

func get_current_quest():
	for quest in quests:
		if quest["quest_id"] == current_quest_id:
			return quest
	return null

func set_current_quest(id : int):
	current_quest_id = id
	_update_current_quest()
	show_all_quests()

func _finished_quest(quest_id : int):
	for quest in quests:
		if quest["quest_id"] == quest_id:
			quests.erase(quest)
			if quest["quest_id"] == current_quest_id:
				_clean_current_quest()
			return
