extends Control

@onready var health_progress_bar = $CanvasLayer/Control/HealthProgressBar
@onready var radiation_progress_bar = $CanvasLayer/Control/RadiationProgressBar
@onready var warning_rad = $CanvasLayer/Control/WarningRad
@onready var rad_label = $CanvasLayer/Control/RadLabel

@onready var hunger_progress_bar = $CanvasLayer/Control/HungerProgressBar
@onready var thirst_progress_bar = $CanvasLayer/Control/ThirstProgressBar

@onready var quest_recap_container = $CanvasLayer/Control/QuestRecapContainer
@onready var quest_panel = $CanvasLayer/Control/QuestPanel
@onready var quest_text = $CanvasLayer/Control/QuestPanel/QuestText
@onready var all_quest_panel = $CanvasLayer/Control/AllQuestPanel
@onready var all_quest_container : VBoxContainer = $CanvasLayer/Control/AllQuestPanel/AllQuestContainer

@onready var ammo_container = $CanvasLayer/Control/AmmoUI
@onready var ammo_in_stock_text = $CanvasLayer/Control/AmmoInStockText

@onready var panel_inventory = $CanvasLayer/Control/PanelInventory
@onready var inventory_container = $CanvasLayer/Control/PanelInventory/Inventory
@export var inventory_item_ui : PackedScene
@onready var grid_container = $CanvasLayer/Control/PanelInventory/GridContainer

@onready var panel_stats = $CanvasLayer/Control/PanelStats
@onready var name_stat = $CanvasLayer/Control/PanelStats/NameStat
@onready var health_stat = $CanvasLayer/Control/PanelStats/VBoxContainer/HealthStat
@onready var rad_stat = $CanvasLayer/Control/PanelStats/VBoxContainer/RadStat
@onready var xp_stat = $CanvasLayer/Control/PanelStats/VBoxContainer/XPStat
@onready var level_stat = $CanvasLayer/Control/PanelStats/VBoxContainer/LevelStat

@onready var location_text = $CanvasLayer/Control/LocationText

var player : Node2D

func _on_close_quest_panel_button_pressed():
	QuestManager._set_quest_panel_visibility(false)
	player.can_move = true
	player.is_interacting = false
