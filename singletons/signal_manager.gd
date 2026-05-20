extends Node

signal on_player_hit
signal on_game_complete
signal on_gravity_flipped(is_active: bool)
signal on_stage_reset  # ステージリセット時（シーンリロード直前）に発火
