class_name PlaneUpgradeInterface
extends Control

signal launched
signal item_upgraded(item_name)

@export var player_index := -1
@export var launch_button := JOY_BUTTON_START
@export var upgrade_button := JOY_BUTTON_A
@export var upgrades : Array[UpgradableItem] = []

var _resources := 0

@onready var _item_list : ItemList = $PanelContainer/ItemList
@onready var _resources_label : Label = $PanelContainer/Resources


func _ready()->void:
	hide()


func _input(event:InputEvent)->void:
	if not visible:
		return
	
	if event is InputEventJoypadButton and event.is_pressed():
		if event.device == player_index:
			match event.button_index:
				launch_button:
					launched.emit()
				upgrade_button:
					_upgrade_selected_item()


func _upgrade_selected_item()->void:
	var selected_items := _item_list.get_selected_items()
	if selected_items.size() > 0:
		var item_index := selected_items[0]
		var item := upgrades[item_index]
		var item_cost := item.cost
		if _resources >= item_cost:
			_resources -= item_cost
			item.upgrade()
			_generate_item_list(item_index)
			item_upgraded.emit(item.name)
			_resources_label.text = str(_resources)


func open(kills:int)->void:
	show()
	_resources += _kills_to_resources(kills)
	_item_list.grab_focus()
	_generate_item_list()
	_resources_label.text = str(_resources)


func _kills_to_resources(kills:int)->int:
	# triangular scale
	@warning_ignore("narrowing_conversion")
	return (kills * kills + kills) / 2.0


func _generate_item_list(selected_item_index := -1)->void:
	_item_list.clear()
	_create_item_list(selected_item_index)


func _create_item_list(selected_item_index := -1)->void:
	for item:UpgradableItem in upgrades:
		_item_list.add_item(item.name + ": " + str(item.cost))
	
	if selected_item_index != -1:
		_item_list.select(selected_item_index)