extends TextureRect

@onready var bg_cover_1: TextureRect = $BgCover1
@onready var bg_cover_2: TextureRect = $BgCover2
@onready var bg_cover_3: TextureRect = $BgCover3
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	size.x = 21000
	bg_cover_1.size.x = 21000
	bg_cover_2.size.x = 21000
	bg_cover_3.size.x = 21000
	
	
func discover_mid_level():
	animation_player.play("fade_out_1")

func discover_mid_deep_level():
	animation_player.play("fade_out_2")


func discover_deep_level():
	animation_player.play("fade_out_3")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
