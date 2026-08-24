#if os(macOS)
import AVFoundation
import FlutterMacOS

/// ARKAN FORK: the macOS half of "the preview follows the phone".
///
/// An iPhone on Continuity Camera is a webcam, and a webcam does not turn. Held
/// upright over a box, its frame still arrives landscape with the picture lying
/// on its side. macOS 14 tells us which way the phone is actually held —
/// `AVCaptureDevice.RotationCoordinator` — so the frames can be turned to match.
///
/// Flutter has to be told as well: it sizes the preview from the dimensions
/// reported when the camera started, so a frame that becomes portrait while
/// Flutter still expects landscape is drawn stretched. The plugin pushes the
/// new orientation down the existing `deviceOrientation` event channel, which
/// this handler owns on macOS (upstream registers it on iOS only).
final class MacOrientationStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var lastSent: String?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        lastSent = nil
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        lastSent = nil
        return nil
    }

    /// Repeats are dropped: a phone shakes on a stand, and every event costs a
    /// Flutter rebuild of the preview.
    func send(_ orientation: String) {
        guard let sink = eventSink, lastSent != orientation else {
            return
        }
        lastSent = orientation
        sink(orientation)
    }
}

/// How Flutter must size the texture for a given capture rotation.
///
/// The plugin reports the sensor's own dimensions at start — landscape numbers —
/// together with `PORTRAIT_UP`, and Flutter reads that pair as "use these
/// numbers as they are". So a frame that is still landscape stays `PORTRAIT_UP`,
/// and a frame turned onto its end reports a LANDSCAPE value, which is Flutter's
/// signal to swap width and height. The names describe the SCREEN the numbers
/// came from, never the phone in the operator's hand.
func orientationString(forRotationAngle angle: CGFloat) -> String {
    switch Int(angle.rounded()) % 360 {
    case 90:
        return "LANDSCAPE_RIGHT"
    case 270:
        return "LANDSCAPE_LEFT"
    default:
        // 0 and 180 both keep the sensor's own width and height.
        return "PORTRAIT_UP"
    }
}
#endif
