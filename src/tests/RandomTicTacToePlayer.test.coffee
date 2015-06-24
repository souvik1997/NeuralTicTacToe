RandomTicTacToePlayer = require('../RandomTicTacToePlayer')
  .RandomTicTacToePlayer
TicTacToe = require('../TicTacToe').TicTacToe
describe = require('../JasmineShim').describe
describe 'RandomTicTacToePlayer', ->
  x = TicTacToe.player.X
  o = TicTacToe.player.O
  _ = TicTacToe.player.empty
  it 'can initialize', ->
    game = new TicTacToe()
    player = new RandomTicTacToePlayer(game, TicTacToe.player.X)
    expect(player).toBeDefined()
  it 'can make a move', ->
    game = new TicTacToe()
    player = new RandomTicTacToePlayer(game, TicTacToe.player.X)
    player.move()
    expect(game.state).toEqual(TicTacToe.state.inProgress)
    inBoard = false
    for r in [0..2]
      for c in [0..2]
        if game.getPlayerAt(r, c) == TicTacToe.player.X
          inBoard = true
    expect(inBoard).toBeTruthy()
  it 'can make a winning move', ->
    game = new TicTacToe()
    player = new RandomTicTacToePlayer(game, TicTacToe.player.X)
    game.board = [[x,x,_],
                  [o,x,o],
                  [x,_,o]]
    player.move()
    expect(game.state).toEqual(TicTacToe.state.xWin)