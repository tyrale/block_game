import Cocoa

// MARK: Colours

/// The colour values for each tetro.
private let colors: [CGColor] = [
  color(0, 0, 0),       // 0 - unused
  color(255, 242, 0),   // 1 - yellow square
  color(174, 0, 255),   // 2 - purple triple
  color(60, 255, 0),    // 3 - green S
  color(255, 0, 0),     // 4 - red Z
  color(230, 124, 32),  // 5 - orange L left
  color(33, 66, 255),   // 6 - blue L right
  color(74, 198, 255),  // 7 - light blue long
]

/// A helper function for easier initialisation of colours.
private func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> CGColor {
  return CGColor(red: r/255, green: g/255, blue: b/255, alpha: 1.0)
}

// MARK: NSView

final class GameCanvas: NSView {

  var game: Game

  private var frameTimer: FrameTimer?
  private var moveDownTimer: FrameTimer?

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var isFlipped: Bool { true }

  override var acceptsFirstResponder: Bool { true }

  init(frame frameRect: NSRect, game: Game) {
    self.game = game
    super.init(frame: frameRect)
  }

  // MARK: Drawing

  private func setNeedsDisplay() {
    setNeedsDisplay(NSRect(origin: .zero,
                           size: CGSize(width: bounds.width,
                                        height: bounds.height)))
  }

  override func draw(_ dirtyRect: NSRect) {
    drawTetro()
    drawField()
    drawHud(dirtyRect)
  }

  private func drawTetro() {
    for i in 0 ..< tetroSize {
      let tetro = game.tetro[i]
      drawBlock(i: game.tetroPosY + tetro.y,
                j: game.tetroPosX + tetro.x,
                colorIdx: game.tetroIdx + 1)
    }
  }

  private func drawField() {
    for i in 1...game.config.fieldNumberOfRows {
      for j in 1...game.config.fieldNumberOfColumns {
        if game.field[i][j] > 0 {
          drawBlock(i: i, j: j, colorIdx: game.field[i][j])
        }
      }
    }
  }

  private func drawBlock(i: Int, j: Int, colorIdx: Int) {
    let color = tetroColor(for: colorIdx)
    let x = (CGFloat(j - 1) * game.blockSize) + game.margin
    let y = CGFloat(i - 1) * game.blockSize
    let side = game.blockSize - 1.0
    let rectanglePath = NSBezierPath(rect: NSMakeRect(x, y, side, side))
    color.setFill()
    rectanglePath.fill()
  }

  private func tetroColor(for colorIdx: Int) -> NSColor {
    NSColor(cgColor: colors[colorIdx])!
  }

  private func drawHud(_ dirtyRect: NSRect) {
    let scoreRect = NSRect(x: 6, y: 6, width: 400, height: 12)
    drawText("Score: \(game.score)", rect: scoreRect, size: 11.0, alignment: .left)
    if game.state == .gameOver {
      drawStateText(dirtyRect, mainText: "Game Over!", subText: "Press Space to start a new game")
    } else if game.state == .paused {
      drawStateText(dirtyRect, mainText: "Paused", subText: "Press Space to resume")
    }
  }

  private func drawStateText(_ dirtyRect: NSRect, mainText: String, subText: String) {
    let textRectHeight = 32.0
    let textRect = NSRect(x: 0,
                          y: dirtyRect.midY - (textRectHeight / 2),
                          width: dirtyRect.width,
                          height: textRectHeight)
    let textRectanglePath = NSBezierPath(rect: textRect)
    NSColor.black.withAlphaComponent(0.7).setFill()
    textRectanglePath.fill()
    drawText(mainText, rect: textRect, size: 28, alignment: .center)
    let subTextRectHeight = 18.0
    let subTextRect = NSRect(x: 0, y: textRect.maxY, width: dirtyRect.width, height: subTextRectHeight)
    let subTextRectanglePath = NSBezierPath(rect: subTextRect)
    NSColor.black.withAlphaComponent(0.7).setFill()
    subTextRectanglePath.fill()
    drawText(subText, rect: subTextRect, size: 12, alignment: .center)
  }

  private func drawText(_ str: String, rect: NSRect, size: CGFloat, alignment: NSTextAlignment) {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = alignment
    let attrs: [NSAttributedString.Key:Any] = [.font: NSFont(name: "Arial", size: size)!,
                                               .foregroundColor: NSColor.green,
                                               .paragraphStyle: paragraphStyle]
    str.draw(with: rect, options: [.usesLineFragmentOrigin], attributes: attrs, context: nil)
  }

  // MARK: Timers

  func setupTimers() {
    let frameTimer = FrameTimer()
    frameTimer.delegate = self
    frameTimer.setupTimer(interval: 1/30, id: "frame")
    let moveDownTimer = FrameTimer()
    moveDownTimer.delegate = self
    moveDownTimer.setupTimer(interval: 1.0, id: "moveDown")
    self.frameTimer = frameTimer
    self.moveDownTimer = moveDownTimer
  }

  private func destroyTimers() {
    frameTimer?.removeTimer()
    moveDownTimer?.removeTimer()
    frameTimer = nil
    moveDownTimer = nil
  }

  func startNewGame() {
    let gameConfig = GameConfig()
    let game = initGame(config: gameConfig)
    self.game = game
    setupTimers()
  }

  // MARK: Key events

  override func keyDown(with event: NSEvent) {
    switch Int(event.keyCode) {
      case 49: // Space
        switch game.state {
          case .paused:
            setupTimers()
            game.state = .running
          case .running:
            game.state = .paused
            setNeedsDisplay()
            destroyTimers()
          case .gameOver:
            startNewGame()
        }
      case 123: // Left Arrow
        moveTetroHorizontally(&game, dx: -1)
      case 124: // Right Arrow
        moveTetroHorizontally(&game, dx: 1)
      case 125: // Down Arrow
        moveTetroDown(&game)
      case 126: // Up Arrow
        rotateTetro(&game)
      default:
        break
    }
  }
}

extension GameCanvas: FrameTimerDelegate {

  func frameTick(_ currentTime: TimeInterval, id: String) {
    defer {
      setNeedsDisplay()
    }
    guard game.state == .running else {
      destroyTimers()
      return
    }
    if id == "frame" {
      gameFrame(&game, currentTime)
    } else if id == "moveDown" {
      moveTetroDown(&game)
    }
  }
}
