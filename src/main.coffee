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
  third_hidden_layer = []
  for x in [0..3]
    first_hidden_layer.push(new Neuron())
    second_hidden_layer.push(new Neuron())
    third_hidden_layer.push(new Neuron())

  sensory_neurons = []
  output_neurons = []
  for x in [0..2]
    for y in [0..2]
      sensory_neurons.push new SensoryNeuron(text: "("+x+","+y+")")
      output_neurons.push new OutputNeuron(text: "("+x+","+y+")")
  for first in first_hidden_layer
    for second in second_hidden_layer
      network.link(first, second)
  for second in second_hidden_layer
    for third in third_hidden_layer
      network.link(second, third)
  for neuron in sensory_neurons
    for first in first_hidden_layer
      network.link(neuron, first)
  for neuron in output_neurons
    for third in third_hidden_layer
      network.link(third, neuron)

  visualizer = new Visualizer(container, network)
  visualizer.createNodesAndEdges()
  visualizer.draw()
)