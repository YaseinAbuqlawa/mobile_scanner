/// ARKAN FORK: one camera this machine can see.
///
/// Upstream only ever offers a facing direction and a lens type, which on macOS
/// can mean nothing but the built-in camera. A shop counter also has USB
/// cameras and — the reason this exists — the owner's iPhone acting as a
/// Continuity Camera, the only lens that can be carried to a pallet of boxes.
class CameraDevice {
  /// Creates a camera description.
  const CameraDevice({
    required this.id,
    required this.name,
    this.isBuiltIn = true,
    this.isContinuity = false,
  });

  /// Reads one camera from the platform map, or null when it is malformed.
  static CameraDevice? fromMap(Map<Object?, Object?> map) {
    final id = map['id'];
    final name = map['name'];

    // A camera with no id cannot be selected later, so it is not a camera we
    // can offer.
    if (id is! String || id.isEmpty) {
      return null;
    }

    return CameraDevice(
      id: id,
      name: name is String && name.isNotEmpty ? name : id,
      isBuiltIn: map['isBuiltIn'] as bool? ?? true,
      isContinuity: map['isContinuity'] as bool? ?? false,
    );
  }

  /// The stable platform id of this camera (`AVCaptureDevice.uniqueID`).
  ///
  /// Pass it to `MobileScannerController.start(deviceId: ...)`, or store it to
  /// reopen the same camera next time.
  final String id;

  /// The name the operating system shows for this camera.
  final String name;

  /// Whether this is a camera built into the machine.
  final bool isBuiltIn;

  /// Whether this is an iPhone acting as a Continuity Camera.
  final bool isContinuity;

  @override
  String toString() => 'CameraDevice($id, $name)';
}
