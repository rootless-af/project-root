extends Button

@onready var inventory: Node2D = $"../Inventory"
@onready var rich_text_label: RichTextLabel = $"../RichTextLabel"
enum MineralTypes {ENTIVERA, BARBANIUM, RIHTOCIDE, KVIKTORIUM}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	inventory.add_funds(MineralTypes.ENTIVERA, 50)
	inventory.add_funds(MineralTypes.BARBANIUM, 50)
	inventory.add_funds(MineralTypes.RIHTOCIDE, 50)
	inventory.add_funds(MineralTypes.KVIKTORIUM, 50)
	rich_text_label.text = str(inventory.get_minerals())
