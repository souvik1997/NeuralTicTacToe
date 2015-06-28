TicTacToe = require('./TicTacToe').TicTacToe
class NeuralTicTacToePlayer
  constructor: (game, player, network) ->
    @game = game
    @player = player
    @network = network

  setupSensors: () ->
    for r in [0..@game.dimensions.r-1]
      for c in [0..@game.dimensions.c-1]
        sensory_id = 10+r+c/10
        do (r,c) =>
          sensor = @network.findInNetworkByID(sensory_id)
          if sensor != -1
            sensor.on('sense', =>
              player = @game.getPlayerAt(r, c)
              if player == @player
                return 1
              if player == TicTacToe.player.empty
                return 0
              return -1
            )
  getSensorNeuron: (r, c) ->
    sensory_id = 10+r+c/10
    sensor = @network.findInNetworkByID(sensory_id)
    if sensor == -1
      return null
    return sensor

  getOutputNeuron: (r, c) ->
    output_id = 20+r+c/10
    output = @network.findInNetworkByID(output_id)
    if output == -1
      return null
    return output

  move: () ->
    moves = []
    for r in [0..@game.dimensions.r-1]
      for c in [0..@game.dimensions.c-1]
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
    @game.move(moves[0].r, moves[0].c, @player)
    return {r: moves[0].r, c: moves[0].c}


root = module.exports ? this
root.NeuralTicTacToePlayer = NeuralTicTacToePlayer