vis = require('vis/dist/vis.js')
NeuronType = require('./NeuronType').NeuronType
class Visualizer # Wrapper for vis.js
  constructor: (container, network) ->
    @container = container
    @network = network
    @settings = {}
    @settings[NeuronType.generic] = 'rgb(32,145,24)'
    @settings[NeuronType.sensory] = 'rgb(171,20,10)'
    @settings[NeuronType.output] = 'rgb(12,42,180)'
  createNodesAndEdges: () ->
    @nodes = []
    @edges = []
    for neuron in @network.neurons
      color = @settings[neuron.type]
      @nodes.push {id: neuron._id, color: color}
      for dendrite in neuron.dendrites
        @edges.push {
          from: dendrite.neuron._id,
          to: neuron._id,
          value: dendrite.weight
        }
  draw: () ->
    data = {
      nodes: @nodes,
      edges: @edges
    }
    options = {
      nodes: {
        shape: 'dot'
      }
    }
    if @container?
      visnetwork = new vis.Network @container, data, options


root = module.exports ? this
root.Visualizer = Visualizer