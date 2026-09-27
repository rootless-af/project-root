class_name DepthUpgrade
extends RootUpgradeBase

@export var min_depth_upgrade: float = 0
@export var max_depth_upgrade: float = 0

func apply_upgrade(root):
	root.max_depth += max_depth_upgrade
	root.min_depth += min_depth_upgrade
