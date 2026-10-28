extends Node

@onready var address: LineEdit = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressAndPort/Address
@onready var port_entry: LineEdit = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressAndPort/PortEntry

@onready var main_menu: PanelContainer = $CanvasLayer/MainMenu
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var go_button: Button = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/GoButton
@onready var address_and_port: HBoxContainer = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressAndPort

@onready var hud: Control = $CanvasLayer/HUD
@onready var health_bar: ProgressBar = $CanvasLayer/HUD/HealthBar

var PORT = 9989
var peer = ENetMultiplayerPeer.new()

const PLAYER = preload("res://player.tscn")
const HOST = 0
const JOIN = 1


func _ready() -> void:
	PORT = port_entry.text.to_int()
	print("port: ", PORT)
	print(IP.get_local_addresses())

func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("quit"):
		#get_tree().quit()
	pass


func _on_host_button_pressed() -> void:
	main_menu.hide()
	hud.show()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())


func _on_join_button_pressed() -> void:
	main_menu.hide()
	hud.show()
	peer.create_client(address.text, PORT)
	multiplayer.multiplayer_peer = peer
	#add_player(multiplayer.get_unique_id())

func add_player(id):
	var player: Player = PLAYER.instantiate()
	player.name = str(id)
	add_child(player)
	if player.is_multiplayer_authority():
		player.health_changed.connect(update_health_bar)

func remove_player(id):
	var player := get_node_or_null(str(id))
	player.queue_free()

func update_health_bar(value):
	health_bar.value = value


func _on_multiplayer_spawner_spawned(player: Node) -> void:
	if player.is_multiplayer_authority():
		player.health_changed.connect(update_health_bar)


func _on_port_entry_text_changed(new_text: String) -> void:
	PORT = str(new_text).to_int()


func _on_option_button_item_selected(index: int) -> void:
	address_and_port.hide()
	match index:
		HOST:
			address_and_port.show()
			address.hide()
			print(go_button.pressed.get_connections())
			print("hosting")
			for i in go_button.pressed.get_connections():
				go_button.pressed.disconnect(i.callable)
			go_button.pressed.connect(_on_host_button_pressed)
		JOIN:
			address_and_port.show()
			address.show()
			port_entry.show()
			print(go_button.pressed.get_connections())
			print("joining")
			for i in go_button.pressed.get_connections():
				go_button.pressed.disconnect(i.callable)
			go_button.pressed.connect(_on_join_button_pressed)
	print(index)
	print(go_button.pressed.get_connections())
