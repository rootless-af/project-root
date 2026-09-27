extends Node2D

signal finish_game

@onready var background: TextureRect = $"../Background"

@export var mid_level_discover_depth := int(GLOBALS.level_depths.get(GLOBALS.Levels.MID_LEVEL))
@export var mid_deep_level_discover_depth := int(GLOBALS.level_depths.get(GLOBALS.Levels.MID_DEEP_LEVEL))
@export var deep_level_discover_depth := int(GLOBALS.level_depths.get(GLOBALS.Levels.DEEP_LEVEL))
@export var core_level_disover_depth := int(GLOBALS.level_depths.get(GLOBALS.Levels.CORE))

var mid_level_discovered := false
var mid_deep_level_discovered := false
var deep_level_discovered := false
var core_level_discovered := false

func _ready() -> void:
	pass


func handle_depth(level:GLOBALS.Levels):
	match level:
		GLOBALS.Levels.MID_LEVEL:
			if mid_level_discovered:
				return
			discover_mid_level()
		GLOBALS.Levels.MID_DEEP_LEVEL:
			if mid_deep_level_discovered:
				return
			discover_mid_deep_level()
		GLOBALS.Levels.DEEP_LEVEL:
			if deep_level_discovered:
				return
			discover_deep_level()
		GLOBALS.Levels.CORE:
			if core_level_discovered:
				return
			end_game()

func discover_mid_level():
	mid_level_discovered = true
	background.discover_mid_level()

func discover_mid_deep_level():
	mid_deep_level_discovered = true
	background.discover_mid_deep_level()

func discover_deep_level():
	deep_level_discovered = true 
	background.discover_deep_level()

func end_game():
	core_level_discovered = true;
	print("[GAME MANAGER] You completed the game! Congrats!")
	finish_game.emit()


func _on_root_reached_threshold(threshold:GLOBALS.Levels):
	handle_depth(threshold)
