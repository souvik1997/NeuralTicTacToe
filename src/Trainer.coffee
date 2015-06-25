RandomTicTacToePlayer = require('./RandomTicTacToePlayer').RandomTicTacToePlayer
TicTacToe = require('./TicTacToe').TicTacToe
Organism = require('./Organism').Organism
Genome = require('./Genome').Genome
Math = require('./MathPolyfill').Math
class Trainer
  constructor: (network, options) ->
    @network = network
    @options = options
  train: (numgen=10) ->
    getMutationOptions = (k) =>
      opts = {}
      opts.fitInheritanceProbability = @options.fitInheritanceProbability
      opts.mutate = {}
      opts.mutate.weightchange = {}
      opts.mutate.reroute = {}
      opts.mutate.route_insertion = {}
      opts.mutate.route_deletion = {}
      opts.mutate.hiddenlayer_deletion = {}
      opts.mutate.weightchange.probability = @options
        .mutate.weightchange.probability * k
      opts.mutate.weightchange.scale = @options
        .mutate.weightchange.scale * k
      opts.mutate.reroute.probability = @options
        .mutate.reroute.probability * k
      opts.mutate.route_insertion.probability = @options
        .mutate.route_insertion.probability * k
      opts.mutate.route_deletion.probability = @options
        .mutate.route_deletion.probability * k
      opts.mutate.hiddenlayer_deletion.probability = @options
        .mutate.hiddenlayer_deletion.probability * k
      return opts
    getStats = (organism) ->
      o_network = organism.genome.construct()
      game = new TicTacToe()
      if Math.random() < 0.5
        network_player = TicTacToe.player.X
        random_player = TicTacToe.player.O
      else
        network_player = TicTacToe.player.O
        random_player = TicTacToe.player.X
      for r in [0..2]
        for c in [0..2]
          sensory_id = 10+r+c/10
          do (r,c) ->
            sensor = o_network.findInNetworkByID(sensory_id)
            if sensor != -1
              sensor.on('sense', ->
                player = game.getPlayerAt(r, c)
                if player == network_player
                  return 1
                if player == random_player
                  return -1
                return 0
              )
      stats = {
        wins: 0
        losses: 0
        draws: 0
      }
      currentPlayer = TicTacToe.player.X
      for x in [1..100]
        randomTTTPlayer = new RandomTicTacToePlayer(game, random_player, 1)
        while game.state == TicTacToe.state.inProgress
          if random_player == currentPlayer
            randomTTTPlayer.move()
          else if network_player == currentPlayer
            moves = []
            for r in [0..2]
              for c in [0..2]
                if game.getPlayerAt(r, c) == TicTacToe.player.empty
                  output_id = 20+r+c/10
                  output = o_network.findInNetworkByID(output_id)
                  if output != -1
                    moves.push({
                      priority: output.getOutput()
                      r: r
                      c: c
                    })
            moves.sort((a,b) -> b.priority - a.priority)
            game.move(moves[0].r, moves[0].c, network_player)
          if (game.state == TicTacToe.state.xWin and
          network_player == TicTacToe.player.X) or
          (game.state == TicTacToe.state.oWin and
          network_player == TicTacToe.player.O)
            stats.wins++
          else if game.state == TicTacToe.state.draw
            stats.draws++
          else if game.state != TicTacToe.state.inProgress
            stats.losses++
          currentPlayer =
            (if currentPlayer == TicTacToe.player.X then TicTacToe.player.O
            else TicTacToe.player.X)
        game.newGame()
      return stats
    generation = []
    ancestral_genome = new Genome()
    ancestral_genome.deconstruct(@network)
    generation = [new Organism(ancestral_genome),
      new Organism(ancestral_genome)]
    return_statistics = {}
    return_statistics.fitnessValues = []
    return_statistics.wins = 0
    return_statistics.losses = 0
    return_statistics.draws = 0
    for gen in [1..numgen]
      parents = generation
        .sort((a,b) -> b.fitness - a.fitness)
      generation = []
      whattoadd = []
      whattoadd.push(parents[0])
      whattoadd.push(parents[1])
      for x in [1..30]
        if parents[0].isOfSameSpeciesAs(parents[1])
          child =
            parents[0].mate(parents[1], getMutationOptions(
              Math.sigmoid(-parents[0].fitness/2)))
          whattoadd.push(child)
        else
          child1 = parents[0].mate(parents[0], getMutationOptions(
            Math.sigmoid(-parents[0].fitness/2)))
          child2 = parents[1].mate(parents[1], getMutationOptions(
            Math.sigmoid(-parents[1].fitness/2)))
          whattoadd.push(child1)
          whattoadd.push(child2)
      for child in whattoadd
        stats = getStats(child)
        child.fitness =
          @options.weight.win*stats.wins +
          @options.weight.draw*stats.draws +
          @options.weight.loss*stats.losses
        return_statistics.fitnessValues.push(child.fitness)
        return_statistics.wins += stats.wins
        return_statistics.losses += stats.losses
        return_statistics.draws += stats.draws
        generation.push(child)
    parents = generation
      .sort((a,b) -> b.fitness - a.fitness)
    @network = parents[0].genome.construct()
    return return_statistics

root = module.exports ? this
root.Trainer = Trainer
