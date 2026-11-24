# RF-756 (D-237): el preset «Android Play» arma un AAB con Gradle y comparte con «Android» (la APK) el paquete, la
# versión, la arquitectura y los filtros, para que la app de Play y la APK de prueba sean la misma app.
extends GutTest

const PACKAGE: String = "com.monsterscanonsv1.game"
const SHARED_OPTIONS: Array[String] = [
	"package/unique_name",
	"version/code",
	"version/name",
	"architectures/arm64-v8a",
	"architectures/armeabi-v7a",
	"architectures/x86",
	"architectures/x86_64",
]

var _presets: ConfigFile


func before_each() -> void:
	_presets = ConfigFile.new()
	assert_eq(_presets.load("res://export_presets.cfg"), OK)


func _section(preset_name: String) -> String:
	var i: int = 0
	while _presets.has_section("preset.%d" % i):
		if _presets.get_value("preset.%d" % i, "name") == preset_name:
			return "preset.%d" % i
		i += 1
	return ""


func test_play_preset_builds_a_bundle_with_gradle() -> void:
	var play: String = _section("Android Play")
	assert_ne(play, "", "existe el preset de Google Play")
	assert_eq(_presets.get_value(play, "platform"), "Android")
	assert_true(_presets.get_value(play + ".options", "gradle_build/use_gradle_build"), "Play exige AAB, que solo sale con Gradle")
	assert_eq(_presets.get_value(play + ".options", "gradle_build/export_format"), 1, "1 = AAB (0 sería APK)")
	assert_true(str(_presets.get_value(play, "export_path")).ends_with(".aab"))


func test_apk_preset_stays_a_quick_apk() -> void:
	var apk: String = _section("Android")
	assert_false(_presets.get_value(apk + ".options", "gradle_build/use_gradle_build"), "la APK de prueba no necesita Gradle")
	assert_true(str(_presets.get_value(apk, "export_path")).ends_with(".apk"))


func test_both_android_presets_are_the_same_app() -> void:
	var apk: String = _section("Android") + ".options"
	var play: String = _section("Android Play") + ".options"
	assert_eq(_presets.get_value(play, "package/unique_name"), PACKAGE, "el paquete que eligió Lucas; no cambia después de subirlo")
	for option: String in SHARED_OPTIONS:
		assert_eq(_presets.get_value(play, option), _presets.get_value(apk, option), "«%s» igual en la APK y el AAB" % option)
	assert_true(_presets.get_value(play, "architectures/arm64-v8a"), "Play exige 64 bits")
	assert_eq(_presets.get_value(play, "version/name"), "", "el nombre de versión sale de config/version")


func test_play_preset_leaves_out_the_same_files() -> void:
	var apk: String = _section("Android")
	var play: String = _section("Android Play")
	assert_eq(_presets.get_value(play, "exclude_filter"), _presets.get_value(apk, "exclude_filter"), "tests, herramientas, specs y arte fuente quedan afuera")


func test_no_signing_secret_lives_in_the_presets() -> void:
	# Godot guarda la clave en .godot/export_credentials.cfg; si alguna vez aparece acá, vacía no hace daño.
	for preset_name: String in ["Android", "Android Play"]:
		var options: String = _section(preset_name) + ".options"
		for secret: String in ["keystore/release", "keystore/release_user", "keystore/release_password"]:
			assert_eq(str(_presets.get_value(options, secret, "")), "", "%s no versiona «%s»" % [preset_name, secret])
