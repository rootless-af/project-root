class_name AudioShot
extends Resource

@export_group("Audio")
@export var id: StringName;
@export var audio: AudioStream;
@export_range(-80.0,24.0,0.1) var volume_db: float = 0.0;

@export_group("Pitch")
@export var rand_pitch: bool = false;
@export_range(0.0,1.0,0.01) var pitch_randomness: float = 0.1;

@export_group("Playback")
@export var bus: StringName = &"SFX";
@export_range(0.0, 60.0, 0.01) var cooldown: float = 0.0
@export_range(0, 100, 1) var max_instances: int = 0

@export_group("Variation")
@export var variations: Array[AudioStream] = [];
