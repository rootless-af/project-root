class_name GatherSpeedUpgrade
extends RootUpgradeBase

@export var gather_speed_upgrade: float = 0

func apply_upgrade(root):
	root.gather_speed += gather_speed_upgrade
