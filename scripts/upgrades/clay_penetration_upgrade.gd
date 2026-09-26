class_name ClayPenetrationUpgrade
extends RootUpgradeBase

@export var clay_penetration_upgrade: float = 0

func apply_upgrade(root):
	root.clay_penetration += clay_penetration_upgrade
