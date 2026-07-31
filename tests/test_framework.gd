extends RefCounted
## Minimal assertion framework used by the headless test runner.
##
## The runner calls [method begin_test] before each test method, which then uses
## the check_* methods. Failures are collected and reported via
## [method failure_messages] when the whole suite has run.

var _passed: int = 0
var _failed: int = 0
var _failures: Array[String] = []
var _current_test: String = ""


func begin_test(test_name: String) -> void:
	_current_test = test_name


func check_true(value: bool, message: String = "") -> void:
	_register(value, message, "expected true")


func check_false(value: bool, message: String = "") -> void:
	_register(not value, message, "expected false")


func check_equal(actual: Variant, expected: Variant, message: String = "") -> void:
	_register(actual == expected, message, "expected %s, got %s" % [str(expected), str(actual)])


func check_not_equal(actual: Variant, expected: Variant, message: String = "") -> void:
	_register(actual != expected, message, "did not expect %s" % str(expected))


func check_almost_equal(
	actual: float,
	expected: float,
	epsilon: float = 0.001,
	message: String = "",
) -> void:
	_register(
		absf(actual - expected) <= epsilon,
		message,
		"expected %s, got %s (epsilon %s)" % [str(expected), str(actual), str(epsilon)],
	)


func check_null(value: Variant, message: String = "") -> void:
	_register(value == null, message, "expected null, got %s" % str(value))


func check_not_null(value: Variant, message: String = "") -> void:
	_register(value != null, message, "expected a non-null value")


func passed() -> int:
	return _passed


func failed() -> int:
	return _failed


func failure_messages() -> Array[String]:
	return _failures


func _register(ok: bool, message: String, details: String) -> void:
	if ok:
		_passed += 1
		return
	_failed += 1
	var text: String = details
	if not message.is_empty():
		text = "%s — %s" % [message, details]
	_failures.append("[%s] %s" % [_current_test, text])
