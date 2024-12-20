extends StaticBody2D

@export var step : int = 0
@export var xp_rewarded : int = 50
@export var quest_id : int = 0

var quest : Dictionary

func _on_player_enter(body):
	if body.has_method("player") && MultiplayerManager.local_id == body.player_id:
		body._activate_interaction()
		body.interact_object = self

func _on_area_2d_body_exited(body):
	if body.has_method("player") && MultiplayerManager.local_id == body.player_id:
		body._clear_interaction()
		body.interact_object = null

func _interact(player):
	print("step %s" % str(step))
	if step == 0:
		quest = QuestManager.get_quest(quest_id)
		$Exclamation.hide()
		$Waiting.show()
		QuestManager.add_quest(quest_id)
		step += 1
	elif step == 1:
		var item_number = player._get_item_number(quest["quest_item_needed"])
		if item_number >= quest["quest_objective"]:
			QuestManager._update_quest_text("good job, you have enought !")
			print("good job, you have enought !")
			$Waiting.hide()
			step += 1
			player.receive_XP(xp_rewarded)
			QuestManager._finished_quest(quest_id)
		else:
			QuestManager._update_quest_text("Too bad\n" + "I need %s items" % str(quest["quest_objective"]))
	elif step == 2:
		QuestManager._update_quest_text("I don't have anything for you")
		print("I don't have anything for you")
