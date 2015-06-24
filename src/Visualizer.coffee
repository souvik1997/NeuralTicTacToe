vis = require('vis/dist/vis.js')
NeuronType = require('./NeuronType').NeuronType
Math = require('./MathPolyfill').Math
class Visualizer # Wrapper for vis.js
  constructor: (container, options) ->
    @container = container
    @settings = {}
    @settings[NeuronType.generic] = 'rgb(132,245,124)'
    @settings[NeuronType.sensory] = 'rgb(170,189,89)'
    @settings[NeuronType.output] = 'rgb(142,142,180)'
    @options = options
  draw: (network) ->
    @nodes = []
    @edges = []
    for neuron in network.neurons
      color = @settings[neuron.type]
      @nodes.push {id: neuron.id, color: color, label: neuron.text}
      for dendrite in neuron.dendrites
        obj = {
          from: dendrite.neuron.id,
          to: neuron.id,
          value: Math.sigmoid(dendrite.weight),
          arrows:{to:{scaleFactor:0.05}}
        }
        if (dendrite.weight < 0)
          obj.color = 'rgb(200,50,80)'
        else
          obj.color = 'rgb(120,90,190)'
        @edges.push obj
    data = {
      nodes: @nodes,
      edges: @edges
    }
    if @container?
      @visnetwork = new vis.Network @container, data, @options
  destroy: () ->
    if @visnetwork?
      @visnetwork.destroy()


root = module.exports ? this
root.Visualizer = Visualizer