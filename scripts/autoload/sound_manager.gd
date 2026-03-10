extends Node
## Autoload singleton for playing sound effects and music.

var sfx_players: Array[AudioStreamPlayer] = []
var weapon_player: AudioStreamPlayer = null
var music_player: AudioStreamPlayer = null
const MAX_SFX: int = 8

func _ready() -> void:
	# Create a pool of AudioStreamPlayers for SFX
	for i in MAX_SFX:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		sfx_players.append(player)

	# Dedicated weapon sound channel — restarts on each shot, never exhausts pool
	weapon_player = AudioStreamPlayer.new()
	weapon_player.bus = "Master"
	add_child(weapon_player)

	# Music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	music_player.volume_db = -10.0
	add_child(music_player)

func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if not stream:
		return
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.play()
			return
	# All players busy — skip this sound

func play_weapon_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if not stream:
		return
	weapon_player.stream = stream
	weapon_player.volume_db = volume_db
	weapon_player.play()

func play_music(stream: AudioStream, volume_db: float = -10.0) -> void:
	if not stream:
		return
	music_player.stream = stream
	music_player.volume_db = volume_db
	music_player.play()

func stop_music() -> void:
	music_player.stop()
