extends Node
## Headless unit-test runner.
##
## Discovers every tests/test_*.gd file, runs each test_*(framework) method found
## and prints a summary. Quits with exit code 0 when every test passes and 1 when
## any test fails. The runner also removes user://user_data.ini at the end so a
## test run never leaves persisted settings behind.

const FRAMEWORK_SCRIPT: GDScript = preload("res://tests/test_framework.gd")
const TEST_DIR: String = "res://tests"
const TEST_FILE_PREFIX: String = "test_"
const IGNORED_FILES: Array[String] = ["test_framework.gd"]
const DEFAULT_SCREEN_SIZE: Vector2 = Vector2(640, 360)


func _ready() -> void:
	get_tree().quit(await _run_all())


func _run_all() -> int:
	Game.SCREEN_SIZE = DEFAULT_SCREEN_SIZE
	var framework: RefCounted = FRAMEWORK_SCRIPT.new()
	var test_files: Array[String] = _collect_test_files()
	var test_count: int = 0

	for file_path in test_files:
		var test_node: Node = _load_test_node(file_path)
		if test_node == null:
			framework.begin_test(file_path.get_file())
			framework.check_true(false, "failed to load test script")
			continue
		add_child(test_node)
		for method_name in _list_test_methods(test_node):
			test_count += 1
			framework.begin_test("%s.%s" % [file_path.get_file().get_basename(), method_name])
			await test_node.call(method_name, framework)
		test_node.queue_free()

	_cleanup_user_data()
	for i in range(2):
		await get_tree().physics_frame
	var failed: int = framework.failed()
	var passed: int = framework.passed()
	print("")
	print("=== Test results ===")
	print("Tests: %d  Passed: %d  Failed: %d" % [test_count, passed, failed])
	for failure in framework.failure_messages():
		print("  FAIL %s" % failure)
	return 1 if failed > 0 else 0


func _collect_test_files() -> Array[String]:
	var result: Array[String] = []
	var dir := DirAccess.open(TEST_DIR)
	if dir == null:
		return result
	for file_name in dir.get_files():
		if not file_name.ends_with(".gd"):
			continue
		if not file_name.begins_with(TEST_FILE_PREFIX):
			continue
		if IGNORED_FILES.has(file_name):
			continue
		result.append("%s/%s" % [TEST_DIR, file_name])
	result.sort()
	return result


func _load_test_node(file_path: String) -> Node:
	var script: Resource = load(file_path)
	if script == null:
		return null
	return script.new()


func _list_test_methods(node: Node) -> Array[String]:
	var result: Array[String] = []
	for method in node.get_method_list():
		var method_name: StringName = method.name
		if not String(method_name).begins_with(TEST_FILE_PREFIX):
			continue
		if method.args.size() != 1:
			continue
		result.append(String(method_name))
	result.sort()
	return result


func _cleanup_user_data() -> void:
	DirAccess.remove_absolute(Settings.SETTINGS_PATH)
