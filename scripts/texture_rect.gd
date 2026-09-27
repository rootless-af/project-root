extends TextureRect

@onready var bg_cover_1: TextureRect = $BgCover1
@onready var bg_cover_2: TextureRect = $BgCover2
@onready var bg_cover_3: TextureRect = $BgCover3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	size.x = 21000
	bg_cover_1.size.x = 21000
	bg_cover_2.size.x = 21000
	bg_cover_3.size.x = 21000


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
