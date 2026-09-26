class_name MusicTrack
extends Resource

@export var id: StringName;
@export var bpm: float = 120.0;
@export var beats_per_bar: int = 4;
@export var loop_bars: int = 8;
@export var stems: Array[MusicStem];
