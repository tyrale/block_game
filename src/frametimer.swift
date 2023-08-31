import Cocoa

/**
 Sends ticks at regular intervals to advance game state.
 */
final class FrameTimer {

  /// The ID of this object. Used by the delegate to know which frame timer object that
  /// a tick comes from.
  var id: String?

  /// The receiver of ticks from this frame timer.
  weak var delegate: FrameTimerDelegate?

  /// If `true`, this frame timer object is running and sending ticks to it's delegate.
  var isActive: Bool {
    timer != nil
  }

  /// An instance of `Timer`.
  private var timer: Timer?

  /// The current timestamp of this frame timer, in seconds.
  private var currentTime: TimeInterval = 0

  /// The point in time, in seconds, that this frame timer object became active.
  private var frameTimerBeginTime: TimeInterval = 0

  /// Sets up and activates the timer.
  func setupTimer(interval: Double, id: String) {
    guard !isActive else { return }
    self.id = id
    frameTimerBeginTime = CACurrentMediaTime()
    timer = Timer.scheduledTimer(withTimeInterval: interval,
                                      repeats: true,
                                      block: { [weak self] timer in
      self?.frameTick()
    })
  }

  private func frameTick() {
    delegate?.frameTick(currentTime, id: id!)
    let currentMediaTime = CACurrentMediaTime()
    currentTime = currentMediaTime - frameTimerBeginTime
  }

  /// Tears down the timer.
  func removeTimer() {
    timer?.invalidate()
    timer = nil
  }
}

/**
 The delegate of the FrameTimer object that receives ticks.
 */
protocol FrameTimerDelegate: AnyObject {
  func frameTick(_ currentTime: TimeInterval, id: String)
}
