extends StaticBody2D

@export var step : int = 0
@export var item_needed : int = 5
@export var item_id_needed : int = 0
@export var xp_rewarded : int = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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
		$Exclamation.hide()
		$Waiting.show()
		QuestManager.set_quest(0)
		step += 1
	elif step == 1:
		var item_number = player._get_item_number(1)
		if item_number >= item_needed:
			QuestManager._update_quest_text("good job, you have enought !")
			print("good job, you have enought !")
			$Waiting.hide()
			step += 1
			player.receive_XP(xp_rewarded)
		else:
			QuestManager._update_quest_text("Too bad\n" + "I need %s items" % str(item_needed))
			print("Too bad")
			print("I need %s items" % str(item_needed))
	elif step == 2:
		QuestManager._update_quest_text("I don't have anything for you")
		print("I don't have anything for you")
