class_name RockPenetrationUpgrade
extends RootUpgradeBase

@export var rock_penetration_upgrade: float = 0

func apply_upgrade(root):
	root.rock_penetration += rock_penetration_upgrade
