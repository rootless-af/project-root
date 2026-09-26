class_name DepthUpgrade
extends RootUpgradeBase

@export var depth_upgrade: float = 0

func apply_upgrade(root):
	root.max_depth += depth_upgrade
