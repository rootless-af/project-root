class_name BranchTipsUpgrade
extends RootUpgradeBase

@export var active_tips_upgrade: int = 0

func apply_upgrade(root):
	root.max_active_tips += active_tips_upgrade;
