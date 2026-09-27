class_name BranchChanceUpgrade
extends RootUpgradeBase

@export var split_chance_upgrade: float = 0

func apply_upgrade(root):
	root.split_chance += split_chance_upgrade
