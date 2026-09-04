class_name ThemeEngine
extends RefCounted

## fence.theme/v1. Fail closed. Patches are deltas. Undo is refresh.

signal applied

const SCHEMA := "fence.theme/v1"
const STORE := "user://theme.json"
const MANIFEST_PATH := "res://weave/themes/manifest.json"
const DEFAULT_PATH := "res://weave/themes/midnight-rink.json"
const DEFAULTS_PATH := "res://weave/themes/defaults.json"
const CONTRAST_MIN := 4.5
const NUDGE_CLOSE := 0.25

static var current: ThemeEngine

var log_lines: PackedStringArray = PackedStringArray()
var last_error := ""
var preview: Dictionary = {}
var saved: Dictionary = {}
var resolved: Dictionary = {}
var css_vars: Dictionary = {}
var nudged: PackedStringArray = PackedStringArray()
var manifest: Dictionary = {}
var shipped: Dictionary = {}
var shipped_defaults: Dictionary = {}

static func boot_current() -> ThemeEngine:
	current = ThemeEngine.new()
	current.boot()
	return current


func boot() -> bool:
	_reset_log()
	if not _load_shipped():
		return false
	if FileAccess.file_exists(STORE):
		var fa := FileAccess.open(STORE, FileAccess.READ)
		if fa != null:
			var parsed: Variant = _parse_object(fa.get_as_text())
			if typeof(parsed) == TYPE_DICTIONARY:
				if _ingest_merged(parsed, shipped, false):
					saved = _dup(preview)
					_publish()
					return true
				_reset_log()
	if not _ingest_merged({}, shipped, false):
		return false
	saved = _dup(preview)
	_publish()
	return true


func ingest(raw: Dictionary) -> bool:
	var prior := _dup(preview)
	var prior_res := _dup(resolved)
	var prior_css := _dup(css_vars)
	if not _ingest_merged(raw, shipped, false):
		preview = prior
		resolved = prior_res
		css_vars = prior_css
		return false
	_publish()
	return true


func apply_patch(delta: Dictionary) -> bool:
	var prior := _dup(preview)
	var prior_res := _dup(resolved)
	var prior_css := _dup(css_vars)
	var base := preview if not preview.is_empty() else shipped
	if not _ingest_merged(delta, base, true):
		preview = prior
		resolved = prior_res
		css_vars = prior_css
		return false
	_publish()
	return true


func save() -> Error:
	var fa := FileAccess.open(STORE, FileAccess.WRITE)
	if fa == null:
		return FileAccess.get_open_error()
	fa.store_string(JSON.stringify(preview, "\t"))
	saved = _dup(preview)
	return OK


func refresh() -> void:
	_reset_log()
	last_error = ""
	var src := saved if not saved.is_empty() else shipped
	_ingest_merged({}, src, false)
	_publish()


func get_color(key: String) -> Color:
	var v: Variant = resolved.get(key, null)
	if v is Color:
		return v
	return Color(1, 1, 1, 1)


func get_number(key: String) -> float:
	var v: Variant = resolved.get(key, null)
	if typeof(v) == TYPE_FLOAT or typeof(v) == TYPE_INT:
		return float(v)
	return 0.0


func get_font(key: String) -> String:
	var v: Variant = resolved.get(key, "")
	return str(v)


func theme_for_prompt() -> Dictionary:
	return _dup(preview)


func _load_shipped() -> bool:
	manifest = _read_json_dict(MANIFEST_PATH)
	shipped = _read_json_dict(DEFAULT_PATH)
	shipped_defaults = _read_json_dict(DEFAULTS_PATH)
	if manifest.is_empty() or shipped.is_empty():
		last_error = "theme: missing shipped files"
		return false
	return true


func _ingest_merged(incoming: Dictionary, base: Dictionary, is_patch: bool) -> bool:
	last_error = ""
	if not _schema_check(incoming, is_patch):
		return false
	var cleaned := _whitelist(incoming)
	var merged := _dup(base)
	if merged.is_empty():
		merged = _dup(shipped)
	_ensure_defaults(merged)
	_merge_theme(merged, cleaned)
	if not _refs_only(merged):
		return false
	var raw_resolved: Dictionary = {}
	if not _resolve_all(merged, raw_resolved):
		return false
	var typed: Dictionary = {}
	if not _type_check(merged, raw_resolved, typed):
		return false
	if not _contrast_check(typed):
		return false
	preview = merged
	resolved = typed
	css_vars = _to_css(typed)
	return true


func _schema_check(incoming: Dictionary, is_patch: bool) -> bool:
	if incoming.is_empty() and not is_patch:
		return true
	if incoming.is_empty() and is_patch:
		last_error = "theme: empty patch"
		return false
	if incoming.has("$schema"):
		if str(incoming.get("$schema", "")) != SCHEMA:
			last_error = "theme: unrecognized $schema"
			return false
		return true
	if is_patch:
		last_error = "theme: $schema required"
		return false
	if incoming.has("meta") or incoming.has("primitives"):
		last_error = "theme: $schema required"
		return false
	return true


func _whitelist(incoming: Dictionary) -> Dictionary:
	var out := {}
	var top: Array = manifest.get("topLevel", [])
	for key in incoming.keys():
		var ks := str(key)
		if ks == "$schema":
			out[ks] = incoming[key]
			continue
		if not top.has(ks):
			_drop("top-level %s" % ks)
			continue
		match ks:
			"meta":
				out[ks] = _whitelist_meta(incoming[key])
			"primitives":
				out[ks] = _whitelist_primitives(incoming[key])
			"semantic":
				out[ks] = _whitelist_map(incoming[key], manifest.get("semantic", []), "semantic")
			"components":
				out[ks] = _whitelist_map(incoming[key], manifest.get("components", []), "components")
	return out


func _whitelist_meta(raw: Variant) -> Dictionary:
	var out := {}
	if typeof(raw) != TYPE_DICTIONARY:
		return out
	var allowed: Array = manifest.get("meta", [])
	for key in raw.keys():
		var ks := str(key)
		if allowed.has(ks):
			out[ks] = raw[key]
		else:
			_drop("meta.%s" % ks)
	return out


func _whitelist_primitives(raw: Variant) -> Dictionary:
	var out := {}
	if typeof(raw) != TYPE_DICTIONARY:
		return out
	var spec: Dictionary = manifest.get("primitives", {})
	for key in raw.keys():
		var ks := str(key)
		if not spec.has(ks):
			_drop("primitives.%s" % ks)
			continue
		var val: Variant = raw[key]
		match ks:
			"color":
				out[ks] = _whitelist_map(val, spec.get("color", []), "primitives.color")
			"font":
				out[ks] = _whitelist_map(val, spec.get("font", []), "primitives.font")
			"space", "radius", "size":
				if typeof(val) != TYPE_ARRAY:
					_drop("primitives.%s (not an array)" % ks)
					continue
				var cap := int(spec.get(ks, 0))
				var trimmed: Array = []
				var i := 0
				for item in val:
					if i >= cap:
						_drop("primitives.%s.%d" % [ks, i])
					else:
						trimmed.append(item)
					i += 1
				out[ks] = trimmed
	return out


func _whitelist_map(raw: Variant, allowed: Array, prefix: String) -> Dictionary:
	var out := {}
	if typeof(raw) != TYPE_DICTIONARY:
		return out
	for key in raw.keys():
		var ks := str(key)
		if allowed.has(ks):
			out[ks] = raw[key]
		else:
			_drop("%s.%s" % [prefix, ks])
	return out


func _ensure_defaults(merged: Dictionary) -> void:
	if not merged.has("$schema"):
		merged["$schema"] = SCHEMA
	if not merged.has("meta"):
		merged["meta"] = {}
	if not merged.has("primitives"):
		merged["primitives"] = {}
	var prim: Dictionary = merged["primitives"]
	var ship_p: Dictionary = shipped.get("primitives", {})
	if not prim.has("color"):
		prim["color"] = _dup(ship_p.get("color", {}))
	else:
		var col: Dictionary = prim["color"]
		var ship_c: Dictionary = ship_p.get("color", {})
		for k in ship_c.keys():
			if not col.has(k):
				col[k] = ship_c[k]
	for arr_k in ["space", "radius", "size"]:
		if not prim.has(arr_k):
			prim[arr_k] = _dup(ship_p.get(arr_k, []))
	if not prim.has("font"):
		prim["font"] = _dup(ship_p.get("font", {}))
	else:
		var font: Dictionary = prim["font"]
		var ship_f: Dictionary = ship_p.get("font", {})
		for k in ship_f.keys():
			if not font.has(k):
				font[k] = ship_f[k]
	var sem_def: Dictionary = shipped_defaults.get("semantic", shipped.get("semantic", {}))
	var com_def: Dictionary = shipped_defaults.get("components", shipped.get("components", {}))
	if not merged.has("semantic"):
		merged["semantic"] = _dup(sem_def)
	else:
		var sem: Dictionary = merged["semantic"]
		for k in sem_def.keys():
			if not sem.has(k):
				sem[k] = sem_def[k]
	if not merged.has("components"):
		merged["components"] = _dup(com_def)
	else:
		var com: Dictionary = merged["components"]
		for k in com_def.keys():
			if not com.has(k):
				com[k] = com_def[k]


func _merge_theme(dst: Dictionary, src: Dictionary) -> void:
	if src.has("meta"):
		var dm: Dictionary = dst.get("meta", {})
		var sm: Dictionary = src["meta"]
		for k in sm.keys():
			dm[k] = sm[k]
		dst["meta"] = dm
	if src.has("primitives"):
		var dp: Dictionary = dst.get("primitives", {})
		var sp: Dictionary = src["primitives"]
		if sp.has("color"):
			var dc: Dictionary = dp.get("color", {})
			for k in sp["color"].keys():
				dc[k] = sp["color"][k]
			dp["color"] = dc
		if sp.has("font"):
			var df: Dictionary = dp.get("font", {})
			for k in sp["font"].keys():
				df[k] = sp["font"][k]
			dp["font"] = df
		for arr_k in ["space", "radius", "size"]:
			if sp.has(arr_k):
				dp[arr_k] = _dup(sp[arr_k])
		dst["primitives"] = dp
	if src.has("semantic"):
		var ds: Dictionary = dst.get("semantic", {})
		for k in src["semantic"].keys():
			ds[k] = src["semantic"][k]
		dst["semantic"] = ds
	if src.has("components"):
		var dco: Dictionary = dst.get("components", {})
		for k in src["components"].keys():
			dco[k] = src["components"][k]
		dst["components"] = dco
	if src.has("$schema"):
		dst["$schema"] = src["$schema"]


func _refs_only(merged: Dictionary) -> bool:
	for tier in ["semantic", "components"]:
		var block: Dictionary = merged.get(tier, {})
		for k in block.keys():
			var v: Variant = block[k]
			if typeof(v) != TYPE_STRING or not _is_ref(str(v)):
				last_error = "theme: %s.%s must be a {reference}" % [tier, k]
				return false
	var meta: Dictionary = merged.get("meta", {})
	var bases: Array = manifest.get("metaBase", ["dark", "light"])
	if meta.has("base") and not bases.has(str(meta.get("base", ""))):
		last_error = "theme: meta.base must be dark or light"
		return false
	return true


func _resolve_all(merged: Dictionary, into: Dictionary) -> bool:
	var names := _all_names(merged)
	for name in names:
		var stack: PackedStringArray = PackedStringArray()
		var val: Variant = _resolve_name(name, merged, stack)
		if last_error != "":
			return false
		into[name] = val
	return true


func _all_names(merged: Dictionary) -> PackedStringArray:
	var names := PackedStringArray()
	var prim: Dictionary = merged.get("primitives", {})
	var color: Dictionary = prim.get("color", {})
	for k in color.keys():
		names.append("color.%s" % k)
	var font: Dictionary = prim.get("font", {})
	for k in font.keys():
		names.append("font.%s" % k)
	for arr_k in ["space", "radius", "size"]:
		var arr: Array = prim.get(arr_k, [])
		for i in arr.size():
			names.append("%s.%d" % [arr_k, i])
	for k in merged.get("semantic", {}).keys():
		names.append(str(k))
	for k in merged.get("components", {}).keys():
		names.append(str(k))
	return names


func _resolve_name(name: String, merged: Dictionary, stack: PackedStringArray) -> Variant:
	if stack.has(name):
		last_error = "theme: cycle at %s" % name
		return null
	stack.append(name)
	var lit: Variant = _primitive_literal(name, merged)
	if lit != null:
		return lit
	var sem: Dictionary = merged.get("semantic", {})
	if sem.has(name):
		return _follow_ref(str(sem[name]), merged, stack)
	var com: Dictionary = merged.get("components", {})
	if com.has(name):
		return _follow_ref(str(com[name]), merged, stack)
	last_error = "theme: dangling ref %s" % name
	return null


func _follow_ref(token: String, merged: Dictionary, stack: PackedStringArray) -> Variant:
	if not _is_ref(token):
		last_error = "theme: expected {reference}, got %s" % token
		return null
	var inner := _unwrap(token)
	return _resolve_name(inner, merged, stack)


func _primitive_literal(name: String, merged: Dictionary) -> Variant:
	var prim: Dictionary = merged.get("primitives", {})
	if name.begins_with("color."):
		var key := name.substr(6)
		var color: Dictionary = prim.get("color", {})
		if color.has(key):
			return color[key]
		return null
	if name.begins_with("font."):
		var key := name.substr(5)
		var font: Dictionary = prim.get("font", {})
		if font.has(key):
			return font[key]
		return null
	for arr_k in ["space", "radius", "size"]:
		var prefix := arr_k + "."
		if name.begins_with(prefix):
			var rest := name.substr(prefix.length())
			if rest.is_valid_int():
				var arr: Array = prim.get(arr_k, [])
				var idx := int(rest)
				if idx >= 0 and idx < arr.size():
					return arr[idx]
			return null
	return null


func _type_check(merged: Dictionary, raw: Dictionary, typed: Dictionary) -> bool:
	var prim: Dictionary = merged.get("primitives", {})
	var color: Dictionary = prim.get("color", {})
	for k in color.keys():
		var name := "color.%s" % k
		var parsed: Variant = _parse_color(str(raw.get(name, "")))
		if parsed == null:
			last_error = "theme: %s is not a color" % name
			return false
		typed[name] = parsed
	var font: Dictionary = prim.get("font", {})
	for k in font.keys():
		var name := "font.%s" % k
		var v: Variant = raw.get(name, "")
		if typeof(v) != TYPE_STRING or str(v).strip_edges() == "":
			last_error = "theme: %s is not a font name" % name
			return false
		typed[name] = str(v)
	for arr_k in ["space", "radius", "size"]:
		var arr: Array = prim.get(arr_k, [])
		for i in arr.size():
			var name := "%s.%d" % [arr_k, i]
			var v: Variant = raw.get(name, null)
			if typeof(v) != TYPE_FLOAT and typeof(v) != TYPE_INT:
				last_error = "theme: %s is not a number" % name
				return false
			typed[name] = float(v)
	for tier in ["semantic", "components"]:
		var block: Dictionary = merged.get(tier, {})
		for k in block.keys():
			var name := str(k)
			var src: Variant = raw.get(name, null)
			if typed.has(name):
				continue
			if src is Color:
				typed[name] = src
				continue
			if typeof(src) == TYPE_FLOAT or typeof(src) == TYPE_INT:
				typed[name] = float(src)
				continue
			if typeof(src) == TYPE_STRING:
				var as_color: Variant = _parse_color(str(src))
				if as_color != null:
					typed[name] = as_color
				else:
					typed[name] = str(src)
				continue
			last_error = "theme: %s failed type check" % name
			return false
	return true


func _contrast_check(typed: Dictionary) -> bool:
	nudged = PackedStringArray()
	var pairs: Array = manifest.get("contrastPairs", [])
	for pair in pairs:
		if typeof(pair) != TYPE_ARRAY or pair.size() < 2:
			continue
		var fg_key := str(pair[0])
		var bg_key := str(pair[1])
		var fg: Variant = typed.get(fg_key, null)
		var bg: Variant = typed.get(bg_key, null)
		if not (fg is Color) or not (bg is Color):
			last_error = "theme: contrast pair %s/%s is not color" % [fg_key, bg_key]
			return false
		var result := _nudge_contrast(fg, bg)
		if not result.get("ok", false):
			last_error = "theme: contrast %s ↔ %s failed" % [fg_key, bg_key]
			return false
		if result.get("nudged", false):
			typed[fg_key] = result["color"]
			nudged.append(fg_key)
			_note("theme: nudged %s lightness" % fg_key)
	return true


func _nudge_contrast(fg: Color, bg: Color) -> Dictionary:
	if _contrast(fg, bg) >= CONTRAST_MIN:
		return {"ok": true, "color": fg, "nudged": false}
	var best_t := 99.0
	var best_c := fg
	var recoverable := false
	for toward in [Color.WHITE, Color.BLACK]:
		for i in range(1, 51):
			var t := float(i) / 50.0
			var cand := fg.lerp(toward, t)
			if _contrast(cand, bg) >= CONTRAST_MIN:
				recoverable = true
				if t < best_t:
					best_t = t
					best_c = cand
				break
	if not recoverable:
		return {"ok": false}
	if best_t > NUDGE_CLOSE:
		return {"ok": false}
	return {"ok": true, "color": best_c, "nudged": true}


func _contrast(a: Color, b: Color) -> float:
	var l1 := _rel_lum(a)
	var l2 := _rel_lum(b)
	var hi := maxf(l1, l2)
	var lo := minf(l1, l2)
	return (hi + 0.05) / (lo + 0.05)


func _rel_lum(c: Color) -> float:
	return 0.2126 * _lin(c.r) + 0.7152 * _lin(c.g) + 0.0722 * _lin(c.b)


func _lin(ch: float) -> float:
	if ch <= 0.04045:
		return ch / 12.92
	return pow((ch + 0.055) / 1.055, 2.4)


func _to_css(typed: Dictionary) -> Dictionary:
	var out := {}
	for key in typed.keys():
		var name := "--" + str(key).replace(".", "-")
		out[name] = _css_value(typed[key])
	return out


func _css_value(v: Variant) -> String:
	if v is Color:
		return "#" + (v as Color).to_html(false)
	if typeof(v) == TYPE_FLOAT or typeof(v) == TYPE_INT:
		return "%spx" % [v]
	return str(v)


func _publish() -> void:
	_write_css_root()
	applied.emit()


func _write_css_root() -> void:
	if not OS.has_feature("web"):
		return
	if not Engine.has_singleton("JavaScriptBridge"):
		return
	var payload := JSON.stringify(css_vars)
	JavaScriptBridge.eval(
		"(function(){var r=document.documentElement;var v=%s;for (var k in v){r.style.setProperty(k,v[k]);}})();" % payload,
		true
	)


func _parse_color(s: String) -> Variant:
	var t := s.strip_edges()
	if t.begins_with("#") and t.length() in [4, 5, 7, 9]:
		return Color.html(t)
	return null


func _is_ref(v: String) -> bool:
	if v.length() < 3:
		return false
	if not (v.begins_with("{") and v.ends_with("}")):
		return false
	var inner := v.substr(1, v.length() - 2)
	return inner != "" and not inner.contains("{") and not inner.contains("}")


func _unwrap(v: String) -> String:
	return v.substr(1, v.length() - 2).strip_edges()


func _drop(what: String) -> void:
	_note("theme: dropped unknown key %s" % what)


func _note(line: String) -> void:
	log_lines.append(line)
	push_warning(line)


func _reset_log() -> void:
	log_lines = PackedStringArray()
	nudged = PackedStringArray()


func _read_json_dict(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var fa := FileAccess.open(path, FileAccess.READ)
	if fa == null:
		return {}
	var parsed: Variant = _parse_object(fa.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed


func _parse_object(text: String) -> Variant:
	var json := JSON.new()
	if json.parse(text) != OK:
		return null
	if typeof(json.data) != TYPE_DICTIONARY:
		return null
	return json.data


func _dup(v: Variant) -> Variant:
	if typeof(v) == TYPE_DICTIONARY or typeof(v) == TYPE_ARRAY:
		return JSON.parse_string(JSON.stringify(v))
	return v
