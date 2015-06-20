jQuery = require('jquery')
Neuron = require('./Neuron').Neuron
SensoryNeuron = require('./Neuron').SensoryNeuron
OutputNeuron = require('./Neuron').OutputNeuron
Visualizer = require('./Visualizer').Visualizer
NeuralNetwork = require('./NeuralNetwork').NeuralNetwork
jQuery(() ->
  container = jQuery("#mynetwork")[0]
  network = new NeuralNetwork()
  console.log "initializing"
  first_hidden_layer = []
  second_hidden_layer = []
  for x in [0..3]
    first_hidden_layer.push(new Neuron())
    second_hidden_layer.push(new Neuron())

  sensory_neurons = []
  output_neurons = []
  pick_random = (arr) ->
    return arr[Math.floor(Math.random() * arr.length)]
  for x in [0..2]
    for y in [0..2]
      sensory_neurons.push new SensoryNeuron("("+x+","+y+")")
      output_neurons.push new OutputNeuron("("+x+","+y+")")
  for first in first_hidden_layer
    for second in second_hidden_layer
      network.linkToEnd(first, second, Math.random())
  for neuron in sensory_neurons
    for first in first_hidden_layer
      network.linkToStart(neuron, first, Math.random())
  for neuron in output_neurons
    for second in second_hidden_layer
      network.linkToEnd(second, neuron, Math.random())

  visualizer = new Visualizer(container, network)
  visualizer.createNodesAndEdges()
  visualizer.draw()
)