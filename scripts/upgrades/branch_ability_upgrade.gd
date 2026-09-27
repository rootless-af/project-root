class_name BranchAbilityUpgrade
extends RootUpgradeBase

@export var split_chance_upgrade: float = 0
@export var max_active_tips_upgrade: int = 0

func apply_upgrade(root):
	root.split_chance += split_chance_upgrade
	root.max_active_tips += max_active_tips_upgrade
