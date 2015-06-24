jQuery = require('jquery')
Neuron = require('./Neuron').Neuron
SensoryNeuron = require('./Neuron').SensoryNeuron
OutputNeuron = require('./Neuron').OutputNeuron
Visualizer = require('./Visualizer').Visualizer
NeuralNetwork = require('./NeuralNetwork').NeuralNetwork
Genome = require('./Genome').Genome
if window?
  window.$ = window.jQuery = jQuery
  Bootstrap = require('bootstrap/dist/js/npm')


start_visualize = ->
  if @visualizer
    @visualizer.draw(@network)

destroy_visualize = ->
  if @visualizer
    @visualizer.destroy()
jQuery(() ->
  container = $("#mynetwork")[0]
  @visualizer = new Visualizer(container, {
    physics:
      timestep: 0.1
    height: "60%"
  })
  @network = new NeuralNetwork()
  console.log "initializing"
  sensory_neurons = []
  output_neurons = []
  for x in [0..2]
    for y in [0..2]
      sensory_neurons.push new SensoryNeuron(text: "("+x+","+y+")")
      output_neurons.push new OutputNeuron(text: "("+x+","+y+")")
  for s in sensory_neurons
    for o in output_neurons
      @network.link(s, o)
  $("#modal-toggle").click( =>
    $("#mymodal").modal({show: true, backdrop: 'static', keyboard: false})
    if @visualizer
      @visualizer.draw(@network)
  )
  $("#modal-close").click( =>
    $("#mymodal").modal('hide')
    if @visualizer
      @visualizer.destroy()
  )
)