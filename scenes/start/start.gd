extends StaticBody2D

# プレイヤーのリスポーン位置を指定するマーカー
@onready var marker_2d: Marker2D = $Marker2D

# プレイヤーへの参照
var player: Player

func _ready() -> void:
	# プレイヤーのノードを取得
	player = get_tree().get_first_node_in_group("player")
	# プレイヤーがダメージを受けたときのシグナルに接続
	SignalManager.on_player_hit.connect(_on_player_hit)

# プレイヤーがダメージを受けたときに呼ばれる巻数
func _on_player_hit():
	# プレイヤーの位置をリスポーン位置に変更
	player.global_position = marker_2d.global_position
	player.animated_sprite_2d.flip_h = false
