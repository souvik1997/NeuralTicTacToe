TicTacToe = require('./TicTacToe').TicTacToe
class IdealTicTacToePlayer
  constructor: (game, player, depth=5) ->
    @game = game
    @player = player
    @depth = depth

  move: () ->
    choice = {}
    if @player == TicTacToe.player.X
      other_player = TicTacToe.player.O
    else
      other_player = TicTacToe.player.X
    bestMove = {score: -Infinity}
    alphabeta = (game, alpha=-Infinity, beta=Infinity, depth=0) =>
      score = (game) =>
        if game.state == @player
          return 10
        else if game.state == other_player
          return -10
        else
          return 0
      ret = 0
      if game.state != TicTacToe.state.inProgress or depth >= @depth
        return score(game)
      for r in [0..@game.dimensions.r-1]
        for c in [0..@game.dimensions.c-1]
          do (r,c) =>
            if game.getPlayerAt(r,c) == TicTacToe.player.empty
              clone_game = game.clone()
              clone_game.move(r, c, clone_game.currentPlayer)
              child = alphabeta(clone_game, alpha, beta, depth + 1)
              if game.currentPlayer == @player
                ret = alpha = Math.max(alpha, child)
              else
                ret = beta = Math.min(beta, child)
          if alpha >= beta
            break
      return ret
    for r in [0..@game.dimensions.r-1]
      for c in [0..@game.dimensions.c-1]
        do (r,c) =>
          if @game.getPlayerAt(r,c) == TicTacToe.player.empty
            cloned_game = @game.clone()
            cloned_game.move(r, c, @player)
            score = alphabeta(cloned_game)
            if score > bestMove.score or
            (score == bestMove.score and Math.random() < 0.5)
              bestMove.r = r
              bestMove.c = c
              bestMove.score = score
    @game.move(bestMove.r, bestMove.c, @player)
    return bestMove



root = module.exports ? this
root.IdealTicTacToePlayer = IdealTicTacToePlayer