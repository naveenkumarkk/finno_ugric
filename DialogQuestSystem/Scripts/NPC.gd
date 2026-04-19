### NPC.gd

extends CharacterBody2D

# Node refs
@onready var dialog_manager = $DialogManager

# Dialog Vars
@export var npc_id: String
@export var npc_name: String
@export var dialog_resource: Dialog
var current_state = "start"
var current_branch_index = 0

# Quest Vars
@export var quests: Array[Quest] = [] 
var quest_manager : Node = null

func _ready():
	# Init (quest_manager no longer used — NPCs are dialog-only in current build)
	if dialog_manager:
		dialog_manager.npc = self
	if not dialog_resource:
		dialog_resource = Dialog.new()
	dialog_resource.load_from_json("res://Resources/Dialog/dialog_data.json")
	print("NPC Ready: Quests loaded", quests.size())

# Starts dialog
func start_dialog():
	var npc_dialogs = dialog_resource.get_npc_dialog(npc_id)
	if npc_dialogs.is_empty():
		return 
	dialog_manager.show_dialog(self)

# Gets current dialog branch value
func get_current_dialog():
	var npc_dialogs = dialog_resource.get_npc_dialog(npc_id)
	if current_branch_index < npc_dialogs.size():
		for dialog in npc_dialogs[current_branch_index]["dialogs"]:
			if dialog["state"] == current_state:
				return dialog
	return null 

# Updates dialog state
func set_dialog_branch(branch_index):
	current_branch_index = branch_index
	current_state = "start"
	
func set_dialog_state(state):
	current_state = state

# Offer quest at required branch — kept for future use
func offer_quest(_quest_id: String):
	pass

# Gets quest dialog — kept for future use
func get_quest_dialog() -> Dictionary:
	return {"text": "", "options": {}}
