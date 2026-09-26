class_name Upgrade
extends Node2D

@export var upgrade_base:RootUpgradeBase

func _ready() -> void:
	upgrade_base.apply_upgrade(get_parent())
