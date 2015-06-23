TicTacToe = require('../TicTacToe').TicTacToe
describe = require('../JasmineShim').describe
describe 'TicTacToe', ->
  x = TicTacToe.player.X
  o = TicTacToe.player.O
  _ = TicTacToe.player.empty
  it 'can initialize', ->
    game = new TicTacToe()
    expect(game).toBeDefined()
  it 'can move players', ->
    game = new TicTacToe()
    expect(game.board[0][0]).toEqual(TicTacToe.player.empty)
    game.move(0, 0, TicTacToe.player.X)
    expect(game.board[0][0]).toEqual(TicTacToe.player.X)
  it 'can retrieve players', ->
    game = new TicTacToe()
    expect(game.getPlayerAt(0,0)).toEqual(TicTacToe.player.empty)
    game.move(0, 0, TicTacToe.player.X)
    expect(game.getPlayerAt(0,0)).toEqual(TicTacToe.player.X)
  it 'can detect wins', ->
    game = new TicTacToe()
    game.board = [[x,x,_],
                  [o,x,o],
                  [x,_,o]]
    expect(game.getPlayerAt(0,2)).toEqual(TicTacToe.player.empty)
    expect(game.move(0, 2, TicTacToe.player.X)).toEqual(TicTacToe.state.xWin)
    expect(game.getPlayerAt(0,2)).toEqual(TicTacToe.player.X)
  it 'can detect a draw', ->
    game = new TicTacToe()
    game.board = [[x,o,_],
                  [o,o,x],
                  [x,x,o]]
    expect(game.move(0, 2, TicTacToe.player.X)).toEqual(TicTacToe.state.draw)
  it 'can handle ambigious win', ->
    game = new TicTacToe()
    game.board = [[x,x,_],
                  [o,o,o],
                  [x,x,o]]
    expect(game.move(0, 2, TicTacToe.player.X)).toEqual(TicTacToe.state.xWin)