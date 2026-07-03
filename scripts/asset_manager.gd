## ⬢ asset_manager.gd ⬢
## Autoload Singleton acting as a centralized dynamic slicing library for atlas sheets.
## Optimizes memory footprint by creating reusable dynamic AtlasTextures at runtime.
extends Node

# --- STORAGE ---
var banner_atlas: Dictionary = {} # Key: String -> Value: AtlasTexture
var icon_atlas: Dictionary = {}   # Key: String -> Value: AtlasTexture

# --- ENGINE CORES ---

func _ready() -> void:
	_load_resources()

# --- INTERNAL METHODS ---

## Validates paths and loads target atlas textures using engine-safe resource checks.
func _load_resources() -> void:
	var banner_path: String = "res://assets/ui/banner_sheet.png"
	var icon_path: String = "res://assets/ui/icon_grid.png"
	
	# ResourceLoader is preferred over FileAccess in Godot 4 for exported resources
	if ResourceLoader.exists(banner_path):
		var banner_tex: Texture2D = load(banner_path) as Texture2D
		if banner_tex:
			_slice_banners(banner_tex)
			
	if ResourceLoader.exists(icon_path):
		var icon_tex: Texture2D = load(icon_path) as Texture2D
		if icon_tex:
			_slice_icons(icon_tex)

## Slices a 2x7 layout banner sheet dynamically into individual AtlasTextures.
func _slice_banners(p_tex: Texture2D) -> void:
	var names: Array[String] = [
		"WOLF", "SHARK", "BEE", "PHOENIX", "EAGLE", "SPIDER", 
		"ELEMENT_FOREST", "ELEMENT_STORM", "ELEMENT_HONEY", "ELEMENT_FIRE", "ELEMENT_WIND", "ELEMENT_WEB", 
		"UI_OPTIONS", "UI_NEUTRAL"
	]
	
	# Using integer divisions to prevent sub-pixel rendering bugs
	var b_width: int = int(p_tex.get_width() / 2.0)
	var b_height: int = int(p_tex.get_height() / 7.0)
	
	for i in range(names.size()):
		var atlas_tex := AtlasTexture.new()
		atlas_tex.atlas = p_tex
		
		# Row/Column calculation using integer math to ensure exact pixel boundaries
		var col: int = i % 2
		var row: int = int(i / 2.0)
		
		atlas_tex.region = Rect2(col * b_width, row * b_height, b_width, b_height)
		banner_atlas[names[i]] = atlas_tex

## Slices a 6-column uniform square icon grid into individual AtlasTextures.
func _slice_icons(p_tex: Texture2D) -> void:
	var names: Array[String] = [
		"ICON_WOLF", "ICON_SHARK", "ICON_BEE", "ICON_PHOENIX", "ICON_SPIDER", "ICON_EAGLE", 
		"ICON_FOREST", "ICON_STORM", "ICON_HONEY", "ICON_FIRE", "ICON_WEB", "ICON_WIND", 
		"ICON_GEAR", "ICON_CELL", "ICON_FLOW"
	]
	
	# Assumes uniform squares based on grid width divided by columns
	var i_size: int = int(p_tex.get_width() / 6.0)
	
	for i in range(names.size()):
		var atlas_tex := AtlasTexture.new()
		atlas_tex.atlas = p_tex
		
		var col: int = i % 6
		var row: int = int(i / 6.0)
		
		atlas_tex.region = Rect2(col * i_size, row * i_size, i_size, i_size)
		icon_atlas[names[i]] = atlas_tex

# --- PUBLIC API ---

## Returns the sliced AtlasTexture banner matching the target key.
func get_banner(p_name: String) -> AtlasTexture:
	return banner_atlas.get(p_name, null) as AtlasTexture

## Returns the sliced AtlasTexture icon matching the target key.
func get_icon(p_name: String) -> AtlasTexture:
	return icon_atlas.get(p_name, null) as AtlasTexture