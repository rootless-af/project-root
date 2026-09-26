class_name WidthUpgrade
extends RootUpgradeBase

@export var root_width_upgrade: float = 0

func apply_upgrade(root):
	root.root_width += root_width_upgrade
