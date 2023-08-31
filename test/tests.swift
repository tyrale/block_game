import XCTest
@testable import Tetris

final class TetrisTests: XCTestCase {

  func testInitGame() throws {
    let config = GameConfig()
    let game = initGame(config: config)
    let noOfTetroTypes = 7
    let expTetroBlockCount = tetroSize * tetroSize * noOfTetroTypes
    XCTAssertEqual(game.tetrosCache.count, expTetroBlockCount)
    XCTAssertEqual(game.field.count, config.fieldNumberOfRows + 2)
    XCTAssertEqual(game.field[0].count, config.fieldNumberOfColumns + 2)
    XCTAssertEqual(game.completedLines, 0)
    XCTAssertEqual(game.score, 0)
  }

  func testGenerateField() throws {
    let field = generateField(columnCount: 3, rowCount: 4)
    let expectation = [
      [-1, -1, -1, -1, -1],
      [-1,  0,  0,  0, -1],
      [-1,  0,  0,  0, -1],
      [-1,  0,  0,  0, -1],
      [-1,  0,  0,  0, -1],
      [-1, -1, -1, -1, -1],
    ]
    XCTAssertEqual(field, expectation)
    printGameField(field)
    print("")
  }

  func testDeleteOneCompletedLine() throws {
    let config = GameConfig(fieldNumberOfColumns: 3, fieldNumberOfRows: 4)
    var game = Game(config: config)
    let fieldBeforeClear = [
      [-1, -1, -1, -1, -1],
      [-1,  0,  0,  0, -1],
      [-1,  0,  0,  0, -1],
      [-1,  0,  0,  0, -1],
      [-1,  2,  2,  2, -1],
      [-1, -1, -1, -1, -1],
    ]
    let fieldAfterClear = [
      [-1, -1, -1, -1, -1],
      [-1,  0,  0,  0, -1],
      [-1,  0,  0,  0, -1],
      [-1,  0,  0,  0, -1],
      [-1,  0,  0,  0, -1],
      [-1, -1, -1, -1, -1],
    ]
    game.field = fieldBeforeClear
    deleteCompletedLines(&game)
    XCTAssertEqual(game.field, fieldAfterClear)
    XCTAssertEqual(game.completedLines, 1)
    printGameField(game.field)
    print("")
  }

  func testDeleteOneCompletedLine2() throws {
    let config = GameConfig(fieldNumberOfColumns: 3, fieldNumberOfRows: 4)
    var game = Game(config: config)
    let fieldBeforeClear = [
      [-1, -1, -1, -1, -1],
      [-1,  0,  0,  0, -1],
      [-1,  0,  0,  0, -1],
      [-1,  2,  0,  1, -1],
      [-1,  2,  2,  2, -1],
      [-1, -1, -1, -1, -1],
    ]
    let fieldAfterClear = [
      [-1, -1, -1, -1, -1],
      [-1,  0,  0,  0, -1],
      [-1,  0,  0,  0, -1],
      [-1,  0,  0,  0, -1],
      [-1,  2,  0,  1, -1],
      [-1, -1, -1, -1, -1],
    ]
    game.field = fieldBeforeClear
    deleteCompletedLines(&game)
    XCTAssertEqual(game.field, fieldAfterClear)
    XCTAssertEqual(game.completedLines, 1)
    printGameField(game.field)
    print("")
  }


  func testDeleteMultipleCompletedLines() throws {
    let config = GameConfig(fieldNumberOfColumns: 3, fieldNumberOfRows: 4)
    var game = Game(config: config)
    let fieldBeforeClear = [
      [-1, -1, -1, -1, -1],
      [-1,  0,  0,  0, -1],
      [-1,  2,  2,  2, -1],
      [-1,  2,  2,  2, -1],
      [-1,  2,  0,  2, -1],
      [-1, -1, -1, -1, -1],
    ]
    let fieldAfterClear = [
      [-1, -1, -1, -1, -1],
      [-1,  0,  0,  0, -1],
      [-1,  0,  0,  0, -1],
      [-1,  0,  0,  0, -1],
      [-1,  2,  0,  2, -1],
      [-1, -1, -1, -1, -1],
    ]
    game.field = fieldBeforeClear
    deleteCompletedLines(&game)
    XCTAssertEqual(game.field, fieldAfterClear)
    XCTAssertEqual(game.completedLines, 2)
    printGameField(game.field)
    print("")
  }

  func testDeleteCustomLine() throws {
    let config = GameConfig(fieldNumberOfColumns: 3, fieldNumberOfRows: 4)
    var game = Game(config: config)
    let rowToDelete = 3
    let fieldBeforeClear = [
      [-1, -1, -1, -1, -1],
      [-1,  0,  0,  0, -1],
      [-1,  2,  2,  2, -1],
      [-1,  1,  2,  3, -1],
      [-1,  1,  0,  2, -1],
      [-1, -1, -1, -1, -1],
    ]
    let fieldAfterClear = [
      [-1, -1, -1, -1, -1],
      [-1,  0,  0,  0, -1],
      [-1,  0,  0,  0, -1],
      [-1,  2,  2,  2, -1],
      [-1,  1,  0,  2, -1],
      [-1, -1, -1, -1, -1],
    ]
    game.field = fieldBeforeClear
    deleteLine(&game, rowToDelete)
    XCTAssertEqual(game.field, fieldAfterClear)
    printGameField(game.field)
    print("")
  }
}
