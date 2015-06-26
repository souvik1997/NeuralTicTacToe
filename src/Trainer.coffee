RandomTicTacToePlayer = require('./RandomTicTacToePlayer').RandomTicTacToePlayer
NeuralTicTacToePlayer = require('./NeuralTicTacToePlayer').NeuralTicTacToePlayer
TicTacToe = require('./TicTacToe').TicTacToe
Organism = require('./Organism').Organism
Genome = require('./Genome').Genome
Math = require('./MathPolyfill').Math
class Trainer
  constructor: (network, options) ->
    @network = network
    @options = options
  train: (network, options, updateFunction) ->
    getMutationOptions = (k) ->
      opts = {}
      opts.fitInheritanceProbability = options.fitInheritanceProbability
      opts.mutate = {}
      opts.mutate.weightchange = {}
      opts.mutate.reroute = {}
      opts.mutate.route_insertion = {}
      opts.mutate.route_deletion = {}
      opts.mutate.hiddenlayer_deletion = {}
      opts.mutate.weightchange.probability = options
        .mutate.weightchange.probability * k
      opts.mutate.weightchange.scale = options
        .mutate.weightchange.scale * k
      opts.mutate.reroute.probability = options
        .mutate.reroute.probability * k
      opts.mutate.route_insertion.probability = options
        .mutate.route_insertion.probability * k
      opts.mutate.route_deletion.probability = options
        .mutate.route_deletion.probability * k
      opts.mutate.hiddenlayer_deletion.probability = options
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
      stats = {
        wins: 0
        losses: 0
        draws: 0
      }
      currentPlayer = TicTacToe.player.X
      randomTTTPlayer = new RandomTicTacToePlayer(game, random_player, 1)
      neuralPlayer = new NeuralTicTacToePlayer(game, network_player, o_network)
      neuralPlayer.setupSensors()
      for x in [1..options.gamesToPlay]
        while game.state == TicTacToe.state.inProgress
          if random_player == currentPlayer
            randomTTTPlayer.move()
          else if network_player == currentPlayer
            neuralPlayer.move()
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
    ancestral_genome.deconstruct(network)
    parents = [new Organism(ancestral_genome),
      new Organism(ancestral_genome)]
    return_statistics = {}
    return_statistics.wins = 0
    return_statistics.losses = 0
    return_statistics.draws = 0
    for gen in [1..options.numGenerations]
      return_statistics.fitnessValues = []
      generation = []
      whattoadd = []
      whattoadd.push(parents[0])
      whattoadd.push(parents[1])
      for x in [1..options.numToCreate]
        if parents[0].isOfSameSpeciesAs(parents[1])
          child =
            parents[0].mate(parents[1], getMutationOptions(
              Math.sigmoid(options.target-parents[0].fitness)))
          whattoadd.push(child)
        else
          child1 = parents[0].mate(parents[0], getMutationOptions(
            Math.sigmoid(options.target-parents[0].fitness)))
          child2 = parents[1].mate(parents[1], getMutationOptions(
            Math.sigmoid(options.target-parents[1].fitness)))
          whattoadd.push(child1)
          whattoadd.push(child2)
      for child in whattoadd
        stats = getStats(child)
        child.fitness =
          options.weight.win*stats.wins +
          options.weight.draw*stats.draws +
          options.weight.loss*stats.losses
        return_statistics.fitnessValues.push(child.fitness)
        return_statistics.wins += stats.wins
        return_statistics.losses += stats.losses
        return_statistics.draws += stats.draws
        child.stats = stats # keep stats along with object
        generation.push(child)
      parents = generation
        .sort((a,b) -> b.fitness - a.fitness)
      return_statistics.best = {}
      return_statistics.best.wins = parents[0].stats.wins
      return_statistics.best.draws = parents[0].stats.draws
      return_statistics.best.losses = parents[0].stats.losses
      return_statistics.network = parents[0].genome.construct()
      if updateFunction?
        updateFunction(return_statistics)
    return return_statistics

root = module.exports ? this
root.Trainer = Trainer
