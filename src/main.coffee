jQuery = require('jquery')
Neuron = require('./Neuron').Neuron
SensoryNeuron = require('./Neuron').SensoryNeuron
OutputNeuron = require('./Neuron').OutputNeuron
Visualizer = require('./Visualizer').Visualizer
NeuralNetwork = require('./NeuralNetwork').NeuralNetwork
jQuery(() ->
  container = jQuery("#mynetwork")[0]
  console.log "initializing"
  sensory_neuron = new SensoryNeuron()
  root_neuron = new Neuron()
  output_neuron = new OutputNeuron()
  network = new NeuralNetwork(root_neuron)
  network.linkToEnd(network.root, output_neuron)
  network.linkToStart(sensory_neuron, network.root)
  visualizer = new Visualizer(container, network)
  visualizer.createNodesAndEdges()
  visualizer.draw()
)