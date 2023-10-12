extends Node2D

@export var char_stats: CharacterStats
@export var music: AudioStream

@onready var player: Player = $Player
@onready var player_handler: PlayerHandler = $PlayerHandler
@onready var enemy_handler: EnemyHandler = $EnemyHandler
@onready var battle_ui: BattleUI = $BattleUI


func _ready() -> void:
	# Normally, we would do this on a 'Run'
	# level so we keep our health, gold and deck
	# between battles.
	var new_stats: CharacterStats = char_stats.create_instance()
	player.stats = new_stats
	battle_ui.char_stats = new_stats
	
	enemy_handler.child_order_changed.connect(_on_enemies_child_order_changed)
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)
	Events.player_turn_ended.connect(player_handler.end_turn)
	Events.player_hand_discarded.connect(enemy_handler.start_turn)
	Events.player_died.connect(_on_player_died)
	start_battle(new_stats)


func start_battle(stats: CharacterStats) -> void:
	enemy_handler.reset_enemy_actions()
	MusicPlayer.play(music, true)
	get_tree().paused = false
	get_tree().create_timer(0.75, false).timeout.connect(
		player_handler.start_battle.bind(stats)
	)


func _on_enemies_child_order_changed() -> void:
	if enemy_handler.get_child_count() == 0:
		Events.battle_over_screen_requested.emit("Victorious!", BattleOverPanel.Type.WIN)


func _on_enemy_turn_ended() -> void:
	player_handler.start_turn()
	enemy_handler.reset_enemy_actions()


func _on_player_died() -> void:
	Events.battle_over_screen_requested.emit("Game Over!", BattleOverPanel.Type.LOSE)