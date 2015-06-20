jQuery = require('jquery')
Neuron = require('./Neuron').Neuron
SensoryNeuron = require('./Neuron').SensoryNeuron
OutputNeuron = require('./Neuron').OutputNeuron
Visualizer = require('./Visualizer').Visualizer
NeuralNetwork = require('./NeuralNetwork').NeuralNetwork
jQuery(() ->
  container = jQuery("#mynetwork")[0]
  network = new NeuralNetwork(new Neuron())
  console.log "initializing"
  preoutput_neuron = new Neuron()
  network.linkToEnd network.root, preoutput_neuron
  first_hidden_layer = []
  second_hidden_layer = []
  for x in [0..10]
    first_hidden_layer.push(new Neuron())
    second_hidden_layer.push(new Neuron())

  blank_sensory_neurons = []
  x_sensory_neurons = []
  o_sensory_neurons = []
  output_neurons = []
  pick_random = (arr) ->
    return arr[Math.floor(Math.random() * arr.length)]
  for x in [0..2]
    for y in [0..2]
      blank_sensory_neurons.push new SensoryNeuron("B ("+x+","+y+")")
      x_sensory_neurons.push new SensoryNeuron("X ("+x+","+y+")")
      o_sensory_neurons.push new SensoryNeuron("O ("+x+","+y+")")
      output_neurons.push new OutputNeuron("("+x+","+y+")")
  for neuron in first_hidden_layer
    network.linkToStart(neuron, network.root)
  for neuron in second_hidden_layer
    network.linkToEnd(network.root, neuron)
  for neuron in blank_sensory_neurons
    network.linkToStart(neuron, pick_random(first_hidden_layer))
  for neuron in x_sensory_neurons
    network.linkToStart(neuron, pick_random(first_hidden_layer))
  for neuron in o_sensory_neurons
    network.linkToStart(neuron, pick_random(first_hidden_layer))
  for neuron in output_neurons
    network.linkToEnd(pick_random(second_hidden_layer), neuron)

  visualizer = new Visualizer(container, network)
  visualizer.createNodesAndEdges()
  visualizer.draw()
)