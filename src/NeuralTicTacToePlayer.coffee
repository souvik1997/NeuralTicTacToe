TicTacToe = require('./TicTacToe').TicTacToe
class NeuralTicTacToePlayer
  constructor: (game, player, network) ->
    @game = game
    @myplayer = player
    @network = network

  setupSensors: () ->
    for r in [0..2]
      for c in [0..2]
        sensory_id = 10+r+c/10
        do (r,c) =>
          sensor = @network.findInNetworkByID(sensory_id)
          if sensor != -1
            sensor.on('sense', =>
              player = @game.getPlayerAt(r, c)
              if player == @myplayer
                return 1
              if player == TicTacToe.player.empty
                return 0
              return -1
            )
  move: () ->
    moves = []
    for r in [0..2]
      for c in [0..2]
        if @game.getPlayerAt(r, c) == TicTacToe.player.empty
          output_id = 20+r+c/10
          output = @network.findInNetworkByID(output_id)
          if output != -1
            moves.push({
              priority: output.getOutput()
              r: r
              c: c
            })
    moves.sort((a,b) -> b.priority - a.priority)
    @game.move(moves[0].r, moves[0].c, @myplayer)
    return {r: moves[0].r, c: moves[0].c}


root = module.exports ? this
root.NeuralTicTacToePlayer = NeuralTicTacToePlayer