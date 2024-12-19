extends Node

var db : Collection = Collection.new("res://Items/DB.tableCollection.res")

#var item : Dictionary = ItemManager.get_item(0)
#print("item_id%s" % str(item["item_id"]))
#print("item_name%s" % item["item_name"])

func get_item(in_item_id : int):
	var all_items_table : Datatable = db.get_table("items")
	var all_items : Array = all_items_table.get_items_list()
	for item in all_items:
		if all_items_table.get_item(item).get("item_id") == in_item_id:
			return all_items_table.get_item(item)
	
	return null
