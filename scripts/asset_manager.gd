## ⬢ asset_manager.gd ⬢ - Central library for sliced textures and icons
extends Node

# --- STORAGE ---
var banner_atlas: Dictionary = {}
var icon_atlas: Dictionary = {}

# --- ENGINE CORES ---

func _ready() -> void:
	_load_resources()

func _load_resources() -> void:
	# Note: Paths must match your folder structure exactly
	var banner_path := "res://assets/ui/banner_sheet.png"
	var icon_path := "res://assets/ui/icon_grid.png"
	
	if FileAccess.file_exists(banner_path):
		_slice_banners(load(banner_path))
	
	if FileAccess.file_exists(icon_path):
		_slice_icons(load(icon_path))

# --- LOGIC ---

func _slice_banners(tex: Texture2D) -> void:
	var names := ["WOLF", "SHARK", "BEE", "PHOENIX", "EAGLE", "SPIDER", "ELEMENT_FOREST", "ELEMENT_STORM", "ELEMENT_HONEY", "ELEMENT_FIRE", "ELEMENT_WIND", "ELEMENT_WEB", "UI_OPTIONS", "UI_NEUTRAL"]
	var b_width := tex.get_width() / 2.0
	var b_height := tex.get_height() / 7.0
	
	for i in range(names.size()):
		var atlas_tex := AtlasTexture.new()
		atlas_tex.atlas = tex
		atlas_tex.region = Rect2((i % 2) * b_width, (i / 2.0) * b_height, b_width, b_height)
		banner_atlas[names[i]] = atlas_tex

func _slice_icons(tex: Texture2D) -> void:
	var names := ["ICON_WOLF", "ICON_SHARK", "ICON_BEE", "ICON_PHOENIX", "ICON_SPIDER", "ICON_EAGLE", "ICON_FOREST", "ICON_STORM", "ICON_HONEY", "ICON_FIRE", "ICON_WEB", "ICON_WIND", "ICON_GEAR", "ICON_CELL", "ICON_FLOW"]
	var i_size := tex.get_width() / 6.0
	
	for i in range(names.size()):
		var atlas_tex := AtlasTexture.new()
		atlas_tex.atlas = tex
		atlas_tex.region = Rect2((i % 6) * i_size, (i / 6.0) * i_size, i_size, i_size)
		icon_atlas[names[i]] = atlas_tex

# --- PUBLIC API ---

func get_banner(p_name: String) -> AtlasTexture:
	return banner_atlas.get(p_name, null)

func get_icon(p_name: String) -> AtlasTexture:
	return icon_atlas.get(p_name, null)
