Neuron = require('./Neuron').Neuron
jQuery = require('jquery')
class NeuralNetwork
  constructor: () ->
    @neurons = []
  add: (neuron) ->
    if not @isInNetwork(neuron)
      @neurons.push(neuron)
  findInNetwork: (neuron) ->
    return (o for o in @neurons when o.equals(neuron))[0] ? -1
  findInNetworkByID: (id) ->
    return (o for o in @neurons when o.id == id)[0] ? -1
  isInNetwork: (neuron) ->
    return @findInNetwork(neuron) != -1
  isInNetworkByID: (id) ->
    return @findInNetworkByID(id) != -1
  link: (prev_neuron, next_neuron, weight=Neuron.generateRandomWeight()) ->
    @add(prev_neuron)
    @add(next_neuron)
    if not @checkCircularReference(prev_neuron, next_neuron)
      next_neuron.addDendrite(prev_neuron, weight)
      return true
    return false
  unlink: (prev_neuron, next_neuron) ->
    index = next_neuron.findDendrite prev_neuron
    if index >= 0
      next_neuron.removeDendrite index
  unlinkFromAll: (neuron) ->
    for n in @neurons
      if n.hasDendrite neuron
        n.removeDendrite n.findDendrite neuron
    neuron.clearDendrites()
  insert: (existing_neuron_prev, new_neuron,
          existing_neuron_next, first_weight=Neuron.generateRandomWeight(),
          second_weight=Neuron.generateRandomWeight()) ->
    @add(existing_neuron_prev)
    @add(new_neuron)
    @add(existing_neuron_next)
    @unlink(existing_neuron_prev, existing_neuron_next)
    @link(existing_neuron_prev, new_neuron)
    @link(new_neuron, existing_neuron_next)
  delete: (index) ->
    neuron = @neurons[index]
  checkCircularReference: (neuron, dendrite) ->
    visited = []
    isCircular = false
    checkCircularReferenceHelper = (n) ->
      if isCircular
        return true
      visited[n.id] = true
      for d in n.dendrites
        ns = d.neuron
        if visited[ns.id]?
          isCircular = true
          return true
        if ns.dendrites.length > 0
          isCircular = checkCircularReferenceHelper(ns) || isCircular
      if n.equals(neuron)
        if visited[dendrite.id]?
          isCircular = true
          return true
        if dendrite.dendrites.length > 0
          isCircular = checkCircularReferenceHelper(dendrite) || isCircular
      return isCircular
    return checkCircularReferenceHelper(neuron)
  clone: () ->
    jQuery.extend true, {}, @

root = module.exports ? this
root.NeuralNetwork = NeuralNetwork




