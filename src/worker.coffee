RandomTicTacToePlayer = require('./RandomTicTacToePlayer').RandomTicTacToePlayer
NeuralTicTacToePlayer = require('./NeuralTicTacToePlayer').NeuralTicTacToePlayer
TicTacToe = require('./TicTacToe').TicTacToe
Organism = require('./Organism').Organism
Genome = require('./Genome').Genome
Math = require('./MathPolyfill').Math
Trainer = require('./Trainer').Trainer
NeuralNetwork = require('./NeuralNetwork').NeuralNetwork
module.exports = (self) ->
  self.addEventListener 'message', (e) ->
    network = NeuralNetwork.fromArray(e.data.network)
    Trainer.trainNEAT(network, e.data.options,
      e.data.numberOfGenerationsSimulated,
      (stats) ->
        postMessage({
          statistics: stats
          options: e.data.options
          network: stats.network
          delta: 1
        })
    )
