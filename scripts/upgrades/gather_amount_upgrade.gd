class_name GatherAmountUpgrade
extends RootUpgradeBase

@export var gather_amount_upgrade: int = 0

func apply_upgrade(root):
	root.gather_amount += gather_amount_upgrade
