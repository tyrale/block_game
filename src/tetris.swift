import CoreGraphics

/// Tetrominos are composed of four blocks.
let tetroSize: Int = 4

/// 4 possible Tetromino shapes are encoded in binary.
/// The "skew" shapes are S and Z.
/// The L shapes can point left or right.
///
/// Square   'T'     'S'     'Z'    'L'L     'L'R
/// 0000 0  0000 0  0000 0  0000 0  0000 0  0000 0
/// 0000 0  0000 0  0000 0  0000 0  0011 3  0011 3
/// 0110 6  0010 2  0011 3  0110 6  0001 1  0010 2
/// 0110 6  0111 7  0110 6  0011 3  0001 1  0010 2
/// There is a special case 1111, since 15 can't be used.
private let bTetros: [[Int]] = [
  [66, 66, 66, 66],
  [27, 131, 72, 232],
  [36, 231, 36, 231],
  [63, 132, 63, 132],
  [311, 17, 223, 74],
  [322, 71, 113, 47],
  [1111, 9, 1111, 9]
]

// MARK: - Game Structs

/// Configuration options for the game field and window.
struct GameConfig {

  /// The width and height value for a block, in points.
  var defaultBlockSize : CGFloat = 20.0

  /// The number of horizontal blocks on screen.
  var fieldNumberOfColumns : Int = 10

  /// The number of vertical blocks on screen.
  var fieldNumberOfRows : Int = 20

  /// The width of the window.
  var winWidth : CGFloat { defaultBlockSize * CGFloat(fieldNumberOfColumns) }

  /// The height of the window.
  var winHeight : CGFloat { defaultBlockSize * CGFloat(fieldNumberOfRows) }
}

/// An on-screen block, or square, that makes up a tetro or blank space on the field.
struct Block {

  /// The x coordinate of the block, in the coordinate system of the field.
  /// The minimum value is 0, the maximum value is `fieldNumberOfColumns` - 1.
  fileprivate(set) var x : Int

  /// The y coordinate of the block, in the coordinate system of the field.
  /// The minimum value is 0, the maximum value is `fieldNumberOfRows` - 1.
  fileprivate(set) var y : Int
}

/// The state of the game instance.
enum GameState {
  case paused, running, gameOver
}


struct Game {

  typealias Tetro = [Block]

  /// Configuration of the current game.
  let config: GameConfig

  /// State of the current game.
  var state: GameState = .running

  /// Score of the current game.
  fileprivate(set) var score: Int = 0

  /// Completed lines of the current game.
  fileprivate(set) var completedLines: Int = 0

  /// Field margin.
  fileprivate(set) var margin: CGFloat = 0.0

  /// field[y][x] contains the color of the block with (x,y) coordinates.
  /// A value of `-1` is a field border to avoid bounds checking.
  /// A value of `0` denotes empty space.
  /// Any value above 0 is a tetro block.
  /// ```
  /// -1 -1 -1 -1
  /// -1  0  0 -1
  /// -1  0  0 -1
  /// -1 -1 -1 -1
  /// ```
  var field: [[Int]] = []

  /// The block size in points within this window.
  var blockSize: CGFloat = 0

  /// A cache that holds every type of tetro in one contiguous array.
  var tetrosCache: [Block] = []

  /// The current tetro.
  var tetro: Tetro = []

  /// x position of the current tetro.
  var tetroPosX: Int = 0

  /// y position of the current tetro.
  var tetroPosY: Int = 0

  /// Index of the current tetro. Refers to its colour.
  var tetroIdx: Int = 0

  /// Index for the next tetro.
  var nextTetroIdx: Int = 0

  /// Index of the rotation (0~3).
  var rotationIdx: Int = 0
}

// MARK: - Setup

/// Initialises a new game with the given config.
func initGame(config: GameConfig) -> Game {
  var game = Game(config: config)
  parseTetros(&game)
  game.nextTetroIdx = Int.random(in: 0 ..< bTetros.count)
  generateTetro(&game)

  let fieldNumberOfColumns = config.fieldNumberOfColumns
  let fieldNumberOfRows = config.fieldNumberOfRows
  game.field = generateField(columnCount: fieldNumberOfColumns, rowCount: fieldNumberOfRows)

  let windowSize: CGSize = CGSize(width: config.winWidth, height: config.winHeight)
  let blockSize = remap(v: config.defaultBlockSize,
                        min: 0.0,
                        max: config.winHeight,
                        newMin: 0.0,
                        newMax: windowSize.height)
  game.blockSize = blockSize
  let margin = (windowSize.width - CGFloat(blockSize) * CGFloat(fieldNumberOfColumns)) * 0.5
  game.margin = margin

  return game
}

func generateField(columnCount: Int, rowCount: Int) -> [[Int]] {
  var field = [[Int]]()

  // Generate the field, fill it with 0's, add -1's on each edge
  for _ in 0 ..< rowCount + 2 {
    let row = generateFieldRow(columnCount)
    field.append(row)
  }

  for j in 0 ..< columnCount + 2 {
    field[0][j] = -1
    field[rowCount + 1][j] = -1
  }
  return field
}

private func generateFieldRow(_ columnCount: Int) -> [Int] {
  var row = Array(repeating: 0, count: columnCount + 2)
  row[0] = -1
  row[columnCount + 1] = -1
  return row
}

private func remap(v: CGFloat, min: CGFloat, max: CGFloat, newMin: CGFloat, newMax: CGFloat) -> CGFloat {
  (((v - min) * (newMax - newMin)) / (max - min)) + newMin
}

private func parseTetros(_ game : inout Game) {
  for row in bTetros {
    for bTetro in row {
      for tetro in parseBinaryTetro(t: bTetro) {
        game.tetrosCache.append(tetro)
      }
    }
  }
}

/// Returns a tetro by converting a base-10 integer to a binary 4 x 4 matrix.
private func parseBinaryTetro(t : Int) -> Game.Tetro {
  var t = t
  var res = Array(repeating: Block(x: 0, y: 0), count: 4)
  var cnt = 0
  let isHorizontal = t == 9 // special case for the horizontal line
  let tenPowers = [1000, 100, 10, 1]
  for i in 0...3 {
    // Get ith digit of t
    let p = tenPowers[i]
    var digit = t / p
    t = t % p
    // Convert the digit to binary
    for j in (0...3).reversed() {
      let bin = digit % 2
      digit = digit / 2
      if bin == 1 || (isHorizontal && i == tetroSize - 1) {
        res[cnt].x = j
        res[cnt].y = i
        cnt += 1
      }
    }
  }
  return res
}

// MARK: - Gameplay

func gameFrame(_ game: inout Game, _ currentTime: Double) {
  updateGameState(&game)
}

private func generateTetro(_ game : inout Game) {
  game.tetroPosY = 0
  game.tetroPosX = (game.config.fieldNumberOfColumns / 2) - (tetroSize / 2)
  game.tetroIdx = game.nextTetroIdx
  game.nextTetroIdx = Int.random(in: 0 ..< bTetros.count)
  game.rotationIdx = 0
  game.tetro = getTetro(&game)
}

private func getTetro(_ game : inout Game) -> Game.Tetro {
  let idx = game.tetroIdx * tetroSize * tetroSize + game.rotationIdx * tetroSize
  return Array(game.tetrosCache[idx ..< idx + tetroSize])
}

func updateGameState(_ game : inout Game) {
  guard game.state == .running else { return }
  deleteCompletedLines(&game)
}

func deleteCompletedLines( _ game : inout Game) {
  for y in (1...game.config.fieldNumberOfRows).reversed() {
    deleteLineIfCompletedAndIncrementScore(&game, y)
  }
}

func deleteLineIfCompletedAndIncrementScore( _ game : inout Game, _ y : Int) {
  for x in 1...game.config.fieldNumberOfColumns {
    if game.field[y][x] == 0 {
      // This line isn't complete
      return
    }
  }
  game.score += 10
  game.completedLines += 1
  // Move everything down one position
  deleteLine(&game, y)
  // We need to check the row again after the field has been updated
  deleteLineIfCompletedAndIncrementScore(&game, y)
}

func deleteLine( _ game : inout Game, _ y : Int) {
  var gameFieldCopy = game.field
  gameFieldCopy.remove(at: y)
  // insert clear row at top of field
  let emptyRow = generateFieldRow(game.config.fieldNumberOfColumns)
  gameFieldCopy.insert(emptyRow, at: 1)
  game.field = gameFieldCopy
}

func dropTetro(_ game : inout Game) {
  for i in 0 ..< tetroSize {
    let tetro = game.tetro[i]
    let x = tetro.x + game.tetroPosX
    let y = tetro.y + game.tetroPosY
    // Remember the color of each block
    game.field[y][x] = game.tetroIdx + 1
  }
}

// MARK: - Moving tetros

func moveTetroDown(_ game : inout Game) {
  guard game.state == .running else { return }
  // Check each block in current tetro
  for block in game.tetro {
    let x = block.x + game.tetroPosX
    let y = block.y + game.tetroPosY + 1
    // Reached the bottom of the screen or another block?
    if game.field[y][x] != 0 {
      // The new tetro has no space to drop => end of the game
      if game.tetroPosY < 2 {
        game.state = .gameOver
        return
      }
      // Drop it and generate a new one
      dropTetro(&game)
      generateTetro(&game)
      return
    }
  }
  game.tetroPosY += 1
}

@discardableResult
func moveTetroHorizontally(_ game : inout Game, dx: Int) -> Bool {
  guard game.state == .running else { return false }
  for i in 0 ..< tetroSize {
    let tetro = game.tetro[i]
    let x = tetro.x + game.tetroPosX + dx
    let y = tetro.y + game.tetroPosY
    if game.field[y][x] != 0 {
      // Do not move
      return false
    }
  }
  game.tetroPosX += dx
  return true
}

func rotateTetro(_ game : inout Game) {
  guard game.state == .running else { return }
  let oldRotationIdx = game.rotationIdx
  game.rotationIdx += 1
  if game.rotationIdx == tetroSize {
    game.rotationIdx = 0
  }
  game.tetro = getTetro(&game)
  if !moveTetroHorizontally(&game, dx: 0) {
    game.rotationIdx = oldRotationIdx
    game.tetro = getTetro(&game)
  }
}

// MARK: - Debugging

#if DEBUG
func printGameField(_ field: [[Int]]) {
  for (n, row) in field.enumerated() {
    printGameFieldRow(row, index: n)
  }
}

func printGameFieldRow(_ fieldRow: [Int], index: Int? = nil) {
  var rowStr = ""
  if let index {
    rowStr = "\(index) "
  }
  for element in fieldRow {
    if element == -1 {
      // Boundary
      rowStr += "区"
    } else if element == 0 {
      // Empty space
      rowStr += "□"
    } else {
      // Tetro
      rowStr += "■"
    }
  }
  print(rowStr)
}
#endif
