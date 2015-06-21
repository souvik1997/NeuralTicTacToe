vis = require('vis/dist/vis.js')
NeuronType = require('./NeuronType').NeuronType
class Visualizer # Wrapper for vis.js
  constructor: (container, network) ->
    @container = container
    @network = network
    @settings = {}
    @settings[NeuronType.generic] = 'rgb(132,245,124)'
    @settings[NeuronType.sensory] = 'rgb(170,189,89)'
    @settings[NeuronType.output] = 'rgb(142,142,180)'
  createNodesAndEdges: () ->
    @nodes = []
    @edges = []
    for neuron in @network.neurons
      color = @settings[neuron.type]
      @nodes.push {id: neuron.id, color: color, label: neuron.text}
      for dendrite in neuron.dendrites
        @edges.push {
          from: dendrite.neuron.id,
          to: neuron.id,
          value: dendrite.weight,
          arrows:{to:{scaleFactor:0.05}}
        }
  draw: () ->
    data = {
      nodes: @nodes,
      edges: @edges
    }
    if @container?
      visnetwork = new vis.Network @container, data, {}


root = module.exports ? this
root.Visualizer = Visualizer