class_name RandomnessUpgrade
extends RootUpgradeBase

@export var randomness_upgrade: float = 0

func apply_upgrade(root):
	root.randomness += randomness_upgrade
