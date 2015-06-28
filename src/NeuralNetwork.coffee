Neuron = require('./Neuron').Neuron
OutputNeuron = require('./Neuron').OutputNeuron
SensoryNeuron = require('./Neuron').SensoryNeuron
NeuronType = require('./NeuronType').NeuronType
extend = require('node.extend')
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
    if not @checkCircularReference(next_neuron, prev_neuron)
      @add(prev_neuron)
      @add(next_neuron)
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
    @unlink(existing_neuron_prev, existing_neuron_next)
    if @link(existing_neuron_prev, new_neuron) and
    @link(new_neuron, existing_neuron_next)
      @add(existing_neuron_prev)
      @add(new_neuron)
      @add(existing_neuron_next)
  delete: (index) ->
    neuron = @neurons[index]
  prune: (preserve...) ->
    visited = []
    whattopreserve = []
    for x in preserve
      whattopreserve[x] = true
    pruneHelper = (neuron, force) =>
      if (force or neuron.dendrites.length > 0 or
      whattopreserve[neuron.type]) and
      not (o for o in visited when o.equals(neuron))[0]?
        visited.push(neuron)
        for n in neuron.dendrites
          dendrite = n.neuron
          value = @findInNetwork(dendrite)
          if value != -1
            pruneHelper(dendrite, true)
    for neuron in @neurons
      pruneHelper(neuron)
    @neurons = visited
  checkCircularReference: (neuron, dendrite) ->
    marked = []
    onstack = []
    cyclic = false
    checkCircularReferenceHelper = (current) ->
      marked[current.id] = true
      onstack[current.id] = true
      for d in current.dendrites
        future = d.neuron
        if not marked[future.id]
          checkCircularReferenceHelper(future)
        else if onstack[future.id]
          cyclic = true
      if current.equals(neuron)
        if not marked[dendrite.id]
          checkCircularReferenceHelper(dendrite)
        else if onstack[dendrite.id]
          cyclic = true
      onstack[current.id] = false
    checkCircularReferenceHelper(neuron)
    return cyclic

  clone: () ->
    extend(true, {}, @)

NeuralNetwork.fromArray = (arr) ->
  network = new NeuralNetwork()
  if not arr?
    return network
  helper = (x) ->
    if x.type == NeuronType.generic
      neuron = new Neuron()
    if x.type == NeuronType.output
      neuron = new OutputNeuron()
    if x.type == NeuronType.sensory
      neuron = new SensoryNeuron()
    neuron.id = x.id
    neuron.text = x.text
    neuron.bias = x.bias
    neuron.dendrites = x.dendrites
    for ds, i in neuron.dendrites
      neuron.dendrites[i].neuron =
        helper(ds.neuron)
    return neuron
  for a in arr.neurons
    network.add(helper(a))
  return network

root = module.exports ? this
root.NeuralNetwork = NeuralNetwork




