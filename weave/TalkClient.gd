class_name TalkClient
extends Node

## User-pointed chat, speech, and hear. No vendor in the deploy.

const VALIDATE_CHAT_TOKENS := 1
const TIMEOUT_SEC := 30.0
const TTS_PROBE := "ok"
const THEME_TOOL := "apply_theme_patch"

var loadout := Loadout.new()
var last_ms := 0
var last_error := ""
var last_kind := ""
var _http: HTTPRequest


func _ready() -> void:
	_ensure_http()


func _ensure_http() -> void:
	if _http != null and is_instance_valid(_http):
		return
	_http = HTTPRequest.new()
	_http.timeout = TIMEOUT_SEC
	add_child(_http)


func reload() -> void:
	loadout.load_local()


func cap_ready(cap: String) -> bool:
	reload()
	for field in Loadout.FIELDS:
		if loadout.get_field(cap, field).strip_edges() == "":
			return false
	return true


func validate_chat() -> Dictionary:
	var started := Time.get_ticks_msec()
	var result := await complete([{"role": "user", "content": "ping"}], VALIDATE_CHAT_TOKENS, [])
	result["ms"] = Time.get_ticks_msec() - started
	return result


func validate_speech() -> Dictionary:
	var started := Time.get_ticks_msec()
	var result := await synthesize(TTS_PROBE)
	result["ms"] = Time.get_ticks_msec() - started
	return result


func validate_hear() -> Dictionary:
	var started := Time.get_ticks_msec()
	var result := await transcribe(sample_wav())
	result["ms"] = Time.get_ticks_msec() - started
	return result


func complete(messages: Array, max_tokens: int, tools: Array) -> Dictionary:
	_ensure_http()
	reload()
	if not cap_ready("chat"):
		return _fail("chat is not pointed", "other")
	var body := {
		"model": loadout.get_field("chat", "model"),
		"messages": messages,
		"max_tokens": max_tokens,
	}
	if not tools.is_empty():
		body["tools"] = tools
		body["tool_choice"] = "auto"
	var res := await _post_json("chat", body)
	if not res.get("ok", false):
		return res
	var data: Variant = res.get("data", {})
	var text := _choice_text(data)
	var calls: Array = _tool_calls(data)
	return {
		"ok": true,
		"text": text,
		"tool_calls": calls,
		"kind": "",
		"error": "",
		"ms": res.get("ms", 0),
	}


func transcribe(audio: PackedByteArray) -> Dictionary:
	_ensure_http()
	reload()
	if not cap_ready("hear"):
		return _fail("hear is not pointed", "other")
	if audio.is_empty():
		return _fail("no audio", "other")
	var boundary := "fence-%d" % Time.get_ticks_msec()
	var crlf := "\r\n"
	var head := PackedByteArray()
	head.append_array(("--%s%s" % [boundary, crlf]).to_utf8_buffer())
	head.append_array(("Content-Disposition: form-data; name=\"model\"%s%s" % [crlf, crlf]).to_utf8_buffer())
	head.append_array(("%s%s" % [loadout.get_field("hear", "model"), crlf]).to_utf8_buffer())
	head.append_array(("--%s%s" % [boundary, crlf]).to_utf8_buffer())
	head.append_array(("Content-Disposition: form-data; name=\"file\"; filename=\"sample.wav\"%s" % crlf).to_utf8_buffer())
	head.append_array(("Content-Type: audio/wav%s%s" % [crlf, crlf]).to_utf8_buffer())
	head.append_array(audio)
	head.append_array(("%s--%s--%s" % [crlf, boundary, crlf]).to_utf8_buffer())
	var headers := _auth_headers("hear")
	headers.append("Content-Type: multipart/form-data; boundary=%s" % boundary)
	var res := await _request(loadout.get_field("hear", "endpoint"), headers, HTTPClient.METHOD_POST, head)
	if not res.get("ok", false):
		return res
	var text := _transcript_text(res.get("data", {}))
	return {"ok": true, "text": text, "kind": "", "error": "", "ms": res.get("ms", 0)}


func synthesize(text: String) -> Dictionary:
	_ensure_http()
	reload()
	if not cap_ready("speech"):
		return _fail("speech is not pointed", "other")
	var body := {
		"model": loadout.get_field("speech", "model"),
		"input": text,
	}
	var headers := _auth_headers("speech")
	headers.append("Content-Type: application/json")
	headers.append("Accept: audio/mpeg, audio/wav, application/json")
	var started := Time.get_ticks_msec()
	var err := _http.request(
		loadout.get_field("speech", "endpoint"),
		PackedStringArray(headers),
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)
	if err != OK:
		return _fail("network unreachable", "offline")
	var completed: Array = await _http.request_completed
	var ms := Time.get_ticks_msec() - started
	var result: int = completed[0]
	var code: int = completed[1]
	var resp_headers: PackedStringArray = completed[2]
	var raw: PackedByteArray = completed[3]
	if result == HTTPRequest.RESULT_TIMEOUT:
		return _fail("provider timeout", "timeout", ms)
	if result != HTTPRequest.RESULT_SUCCESS:
		return _classify_http(result, code, raw, ms)
	if code < 200 or code >= 300:
		return _classify_http(result, code, raw, ms)
	if _looks_json(resp_headers, raw):
		var parsed: Variant = _as_json(raw)
		if typeof(parsed) == TYPE_DICTIONARY and parsed.has("error"):
			return _classify_http(result, code, raw, ms)
	if raw.is_empty():
		return _fail("empty speech", "other", ms)
	return {"ok": true, "audio": raw, "mime": _mime(resp_headers), "kind": "", "error": "", "ms": ms}


func play_audio(audio: PackedByteArray, mime: String) -> void:
	if audio.is_empty():
		return
	if OS.has_feature("web") and Engine.has_singleton("JavaScriptBridge"):
		var b64 := Marshalls.raw_to_base64(audio)
		var safe_mime := mime if mime != "" else "audio/mpeg"
		JavaScriptBridge.eval(
			"(function(){var m=%s;var b=%s;var bin=atob(b);var u=new Uint8Array(bin.length);for(var i=0;i<bin.length;i++)u[i]=bin.charCodeAt(i);var a=new Audio(URL.createObjectURL(new Blob([u],{type:m})));a.play();})();" % [
				JSON.stringify(safe_mime),
				JSON.stringify(b64),
			],
			true
		)
		return
	var player := AudioStreamPlayer.new()
	add_child(player)
	var stream: AudioStream = _stream_for(audio, mime)
	if stream == null:
		player.queue_free()
		return
	player.stream = stream
	player.finished.connect(player.queue_free)
	player.play()


func theme_tools() -> Array:
	return [{
		"type": "function",
		"function": {
			"name": THEME_TOOL,
			"description": "Apply a partial theme token patch. Only primitives may hold literals. semantic and components must be {references}. Unknown keys are dropped. Fail closed.",
			"parameters": {
				"type": "object",
				"properties": {
					"$schema": {"type": "string"},
					"primitives": {"type": "object"},
					"semantic": {"type": "object"},
					"components": {"type": "object"},
				},
			},
		},
	}]


static func sample_wav() -> PackedByteArray:
	var rate := 16000
	var samples := 6400
	var data := PackedByteArray()
	data.resize(samples * 2)
	for i in samples:
		var s := int(sin(TAU * 440.0 * float(i) / float(rate)) * 12000.0)
		data[i * 2] = s & 0xFF
		data[i * 2 + 1] = (s >> 8) & 0xFF
	var out := PackedByteArray()
	out.append_array("RIFF".to_utf8_buffer())
	out.append_array(_u32(36 + data.size()))
	out.append_array("WAVE".to_utf8_buffer())
	out.append_array("fmt ".to_utf8_buffer())
	out.append_array(_u32(16))
	out.append_array(_u16(1))
	out.append_array(_u16(1))
	out.append_array(_u32(rate))
	out.append_array(_u32(rate * 2))
	out.append_array(_u16(2))
	out.append_array(_u16(16))
	out.append_array("data".to_utf8_buffer())
	out.append_array(_u32(data.size()))
	out.append_array(data)
	return out


func _post_json(cap: String, body: Dictionary) -> Dictionary:
	var headers := _auth_headers(cap)
	headers.append("Content-Type: application/json")
	return await _request(loadout.get_field(cap, "endpoint"), headers, HTTPClient.METHOD_POST, JSON.stringify(body).to_utf8_buffer())


func _request(url: String, headers: Array, method: int, body: Variant) -> Dictionary:
	var started := Time.get_ticks_msec()
	var payload: PackedByteArray
	if body is PackedByteArray:
		payload = body
	else:
		payload = str(body).to_utf8_buffer()
	var err := _http.request_raw(url, PackedStringArray(headers), method, payload)
	if err != OK:
		return _fail("network unreachable", "offline")
	var completed: Array = await _http.request_completed
	var ms := Time.get_ticks_msec() - started
	var result: int = completed[0]
	var code: int = completed[1]
	var raw: PackedByteArray = completed[3]
	if result == HTTPRequest.RESULT_TIMEOUT:
		return _fail("provider timeout", "timeout", ms)
	if result != HTTPRequest.RESULT_SUCCESS:
		return _classify_http(result, code, raw, ms)
	if code < 200 or code >= 300:
		return _classify_http(result, code, raw, ms)
	return {"ok": true, "data": _as_json(raw), "raw": raw, "ms": ms}


func _auth_headers(cap: String) -> Array:
	return [
		"Authorization: Bearer %s" % loadout.get_field(cap, "credential"),
	]


func _choice_text(data: Variant) -> String:
	if typeof(data) != TYPE_DICTIONARY:
		return ""
	var choices: Variant = data.get("choices", [])
	if typeof(choices) != TYPE_ARRAY or choices.is_empty():
		if data.has("content"):
			return str(data.get("content", ""))
		return ""
	var first: Variant = choices[0]
	if typeof(first) != TYPE_DICTIONARY:
		return ""
	var msg: Variant = first.get("message", {})
	if typeof(msg) == TYPE_DICTIONARY:
		return str(msg.get("content", ""))
	return str(first.get("text", ""))


func _tool_calls(data: Variant) -> Array:
	if typeof(data) != TYPE_DICTIONARY:
		return []
	var choices: Variant = data.get("choices", [])
	if typeof(choices) != TYPE_ARRAY or choices.is_empty():
		return []
	var first: Variant = choices[0]
	if typeof(first) != TYPE_DICTIONARY:
		return []
	var msg: Variant = first.get("message", {})
	if typeof(msg) != TYPE_DICTIONARY:
		return []
	var calls: Variant = msg.get("tool_calls", [])
	if typeof(calls) != TYPE_ARRAY:
		return []
	return calls


func _transcript_text(data: Variant) -> String:
	if typeof(data) == TYPE_DICTIONARY:
		if data.has("text"):
			return str(data.get("text", ""))
		var rec: Variant = data.get("results", [])
		if typeof(rec) == TYPE_ARRAY and not rec.is_empty() and typeof(rec[0]) == TYPE_DICTIONARY:
			return str(rec[0].get("text", ""))
	return ""


func _classify_http(result: int, code: int, raw: PackedByteArray, ms: int = 0) -> Dictionary:
	var body := raw.get_string_from_utf8().to_lower()
	if result != HTTPRequest.RESULT_SUCCESS:
		if result == HTTPRequest.RESULT_CANT_CONNECT or result == HTTPRequest.RESULT_CANT_RESOLVE:
			return _fail("network unreachable", "offline", ms)
		return _fail("network unreachable", "offline", ms)
	if code == 401 or code == 403:
		return _fail("invalid or revoked key", "revoked", ms)
	if code == 402 or code == 429 or "insufficient_quota" in body or "quota" in body or "credit" in body:
		return _fail("out of credit", "credit", ms)
	if code == 408 or code >= 500:
		return _fail("provider timeout" if code == 408 else "provider error %d" % code, "timeout" if code == 408 else "other", ms)
	return _fail("request failed %d" % code, "other", ms)


func _fail(message: String, kind: String, ms: int = 0) -> Dictionary:
	last_error = message
	last_kind = kind
	last_ms = ms
	return {"ok": false, "error": message, "kind": kind, "text": "", "ms": ms}


func _as_json(raw: PackedByteArray) -> Variant:
	var json := JSON.new()
	if json.parse(raw.get_string_from_utf8()) != OK:
		return {}
	return json.data


func _looks_json(headers: PackedStringArray, raw: PackedByteArray) -> bool:
	for h in headers:
		if h.to_lower().begins_with("content-type:") and "json" in h.to_lower():
			return true
	var t := raw.get_string_from_utf8().strip_edges()
	return t.begins_with("{") or t.begins_with("[")


func _mime(headers: PackedStringArray) -> String:
	for h in headers:
		var low := h.to_lower()
		if low.begins_with("content-type:"):
			return h.split(":")[1].strip_edges().split(";")[0]
	return "audio/mpeg"


func _stream_for(audio: PackedByteArray, mime: String) -> AudioStream:
	var low := mime.to_lower()
	if "wav" in low:
		var wav := AudioStreamWAV.new()
		wav.data = audio
		wav.format = AudioStreamWAV.FORMAT_16_BITS
		return wav
	if "ogg" in low:
		return AudioStreamOggVorbis.load_from_buffer(audio)
	var mp3 := AudioStreamMP3.new()
	mp3.data = audio
	return mp3


static func _u32(n: int) -> PackedByteArray:
	return PackedByteArray([n & 0xFF, (n >> 8) & 0xFF, (n >> 16) & 0xFF, (n >> 24) & 0xFF])


static func _u16(n: int) -> PackedByteArray:
	return PackedByteArray([n & 0xFF, (n >> 8) & 0xFF])
