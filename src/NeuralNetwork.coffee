Neuron = require('./Neuron').Neuron
jQuery = require('jquery')
class NeuralNetwork
  constructor: () ->
    @neurons = []
  add: (neuron) ->
    if not @isInNetwork(neuron)
      @neurons.push(neuron)
  findInNetwork: (neuron) ->
    return (i for o, i in @neurons when o.equals(neuron))[0] ? -1
  isInNetwork: (neuron) ->
    return @findInNetwork(neuron) != -1
  linkToEnd: (existing_neuron, new_neuron, weight=0) ->
    @add(new_neuron)
    @add(existing_neuron)
    new_neuron.addDendrite(existing_neuron, weight)
  linkToStart: (new_neuron, existing_neuron, weight=0) ->
    @add(new_neuron)
    @add(existing_neuron)
    existing_neuron.addDendrite(new_neuron, weight)
  unlinkEnd: (prev_neuron, next_neuron) ->
    index = next_neuron.findDendrite prev_neuron
    if index >= 0
      next_neuron.removeDendrite index
  unlinkFromAll: (neuron) ->
    for n in @neurons
      if n.hasDendrite neuron
        n.removeDendrite n.findDendrite neuron
    neuron.clearDendrites()
  insert: (existing_neuron_prev, new_neuron,
          existing_neuron_next, first_weight=0, second_weight=0) ->
    @add(new_neuron)
    @add(existing_neuron_prev)
    @add(existing_neuron_next)
    @unlinkEnd(existing_neuron_prev, existing_neuron_next)
    @linkToEnd(existing_neuron_prev, new_neuron)
    @linkToStart(new_neuron, existing_neuron_next)
  delete: (index) ->
    neuron = @neurons[index]
  clone: () ->
    jQuery.extend true, {}, @

root = module.exports ? this
root.NeuralNetwork = NeuralNetwork




