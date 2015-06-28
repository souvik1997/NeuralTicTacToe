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
    data = JSON.parse e.data
    network = NeuralNetwork.fromArray(data.neat.network)
    console.log("hi")
    Trainer.trainNEAT(network, data.options,
      data.numberOfGenerationsSimulated,
      (stats) ->
        postMessage({
          update: 'neat'
          neat:
            statistics: stats
            options: data.options
            network: stats.network
            delta: 1
        })
    )
