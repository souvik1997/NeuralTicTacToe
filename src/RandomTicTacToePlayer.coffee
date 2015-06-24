TicTacToe = require('./TicTacToe').TicTacToe
class RandomTicTacToePlayer
  constructor: (game, player, difficulty=0.5) ->
    @game = game
    @myplayer = player
    @difficulty = difficulty

  move: () ->
    definite_move = {none: true}
    possible_moves = []
    if @game.state != TicTacToe.state.inProgress
      return
    if @myplayer == TicTacToe.player.X
      other_player = TicTacToe.player.O
    else
      other_player = TicTacToe.player.X
    for r in [0..2]
      for c in [0..2]
        if @game.getPlayerAt(r, c) == TicTacToe.player.empty
          possible_moves.push({r: r, c: c})
          @game.board[r][c] = @myplayer
          if @game._checkWin(r, c) == @myplayer
            definite_move = {win: true, r: r, c: c}
          if definite_move.none or not definite_move.win
            @game.board[r][c] = other_player
            if @game._checkWin(r, c) == other_player and
            Math.random() < @difficulty
              definite_move = {r: r, c: c}
          @game.board[r][c] = TicTacToe.player.empty
    if definite_move.none
      x = possible_moves[Math.floor(Math.random() * possible_moves.length)]
      @game.move(x.r, x.c, @myplayer)
      return {r: x.r, c: x.c}
    else
      @game.move(definite_move.r, definite_move.c, @myplayer)
      return definite_move

root = module.exports ? this
root.RandomTicTacToePlayer = RandomTicTacToePlayer