class_name GrowthSpeedUpgrade
extends RootUpgradeBase

@export var growth_speed_upgrade: float = 0

func apply_upgrade(root):
	root.growth_speed += growth_speed_upgrade
