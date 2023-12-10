class_name JoinMenu
extends Control

signal game_started(player_colors)

const MAX_PLAYERS := 4

@export var player_colors : Array[Color] = [Color.RED, Color.GREEN, Color.BLUE, Color.BLACK, Color.WEB_MAROON, Color.WHITE]
@export var accept_button := JOY_BUTTON_A
@export var back_button := JOY_BUTTON_B
@export var change_color_left := JOY_BUTTON_LEFT_SHOULDER
@export var change_color_right := JOY_BUTTON_RIGHT_SHOULDER

var _join_banners : Array[JoinBanner] = []
var _players_joined : Array[int] = []
var _players_readied : Array[int] = []
var _used_player_colors : Array[Color] = []
var _players_to_colors := {}
var _game_started := false

@onready var _join_banner_container : HBoxContainer = $JoinBannerContainer


func _ready()->void:
	for player in MAX_PLAYERS:
		_add_join_banner()


func _add_join_banner()->void:
	var join_banner : JoinBanner = load("res://join_menu/join_banner.tscn").instantiate()
	_join_banners.append(join_banner)
	_join_banner_container.add_child(join_banner)


func _input(event:InputEvent)->void:
	if _game_started:
		return
	
	if event is InputEventJoypadButton and event.is_pressed():
		match event.button_index:
			accept_button:
				if not _players_joined.has(event.device):
					_join_player(event.device)
				elif not _players_readied.has(event.device):
					_ready_player(event.device)
				elif _players_readied.size() == _players_joined.size():
					_start_game()
			back_button:
				if _players_readied.has(event.device):
					_unready_player(event.device)
				elif _players_joined.has(event.device):
					_remove_player(event.device)
			change_color_left:
				if _players_joined.has(event.device) and not _players_readied.has(event.device):
					_change_color(event.device, -1)
			change_color_right:
				if _players_joined.has(event.device) and not _players_readied.has(event.device):
					_change_color(event.device, 1)


func _join_player(player_index:int)->void:
	print(_players_joined)
	_players_joined.append(player_index)
	_players_to_colors[player_index] = Color(0, 0, 0, 0)
	_change_color(player_index, 1)
	_join_banners[player_index].joined()


func _ready_player(player_index:int)->void:
	print(_players_readied)
	_players_readied.append(player_index)
	_join_banners[player_index].readied()


func _unready_player(player_index:int)->void:
	print(_players_readied)
	_players_readied.erase(player_index)
	_join_banners[player_index].unreadied()


func _remove_player(player_index:int)->void:
	print(_players_joined)
	_players_joined.erase(player_index)
	_used_player_colors.erase(_players_to_colors[player_index])
	_join_banners[player_index].left()


func _change_color(player_index:int, direction:int)->void:
	var color_index := player_colors.find(_players_to_colors[player_index])
	
	while _used_player_colors.has(player_colors[color_index]):
		color_index += sign(direction)
		color_index %= player_colors.size()
	
	_used_player_colors.erase(_players_to_colors[player_index])
	_players_to_colors[player_index] = player_colors[color_index]
	_used_player_colors.append(_players_to_colors[player_index])
	
	_join_banners[player_index].changed_color(_players_to_colors[player_index])


func _start_game()->void:
	_game_started = true
	game_started.emit(_players_to_colors)
	hide()
