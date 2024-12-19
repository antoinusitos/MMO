extends Node

var player : Node2D

var db : Collection = Collection.new("res://Items/DB.tableCollection.res")

#var item : Dictionary = ItemManager.get_item(0)
#print("item_id%s" % str(item["item_id"]))
#print("item_name%s" % item["item_name"])

var current_quest = {}

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

func set_quest(quest_id : int):
	var all_quests_table : Datatable = db.get_table("quests")
	var all_quests : Array = all_quests_table.get_items_list()
	for quest in all_quests:
		if all_quests_table.get_item(quest).get("quest_id") == quest_id:
			current_quest = all_quests_table.get_item(quest)
			_get_quest_recap(current_quest["quest_description"] + "\n" + "(0/0)")
			_update_quest_text(current_quest["quest_description"])
