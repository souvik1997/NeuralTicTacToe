RandomTicTacToePlayer = require('./RandomTicTacToePlayer').RandomTicTacToePlayer
NeuralTicTacToePlayer = require('./NeuralTicTacToePlayer').NeuralTicTacToePlayer
TicTacToe = require('./TicTacToe').TicTacToe
Organism = require('./Organism').Organism
Genome = require('./Genome').Genome
Math = require('./MathPolyfill').Math
Trainer = require('./Trainer').Trainer
module.exports = (self) ->
  self.addEventListener 'message', (e) ->

    _genome = new Genome()
    _genome.genes = e.data.genome.genes
    network = _genome.construct()
    Trainer.trainNEAT(network, e.data.options,
      e.data.numberOfGenerationsSimulated,
      (stats) ->
        _genome = new Genome()
        _genome.deconstruct(stats.network)
        postMessage({
          statistics: stats
          options: e.data.options
          genome: _genome
          delta: 1
        })
    )
