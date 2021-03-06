Neuron = require('./Neuron').Neuron
NeuronType = require('./NeuronType').NeuronType
SensoryNeuron = require('./Neuron').SensoryNeuron
OutputNeuron = require('./Neuron').OutputNeuron
Visualizer = require('./Visualizer').Visualizer
NeuralNetwork = require('./NeuralNetwork').NeuralNetwork
Math = require('./MathPolyfill').Math
extend = require('node.extend')
class Genome
  constructor: () ->
    @genes = []
  deconstruct: (network, skip_prune=false) ->
    @genes = []
    if not skip_prune
      network.prune(NeuronType.sensory, NeuronType.output)
    for neuron in network.neurons
      @genes.push {
        id: neuron.id,
        type: neuron.type,
        text: neuron.text,
        bias: neuron.bias
      }
      for dendrite in neuron.dendrites
        @genes.push {weight: dendrite.weight,
        from: dendrite.neuron.id, to: neuron.id}
  construct: (skip_prune=false) ->
    network = new NeuralNetwork()
    second_pass = []
    for gene in @genes
      if gene.id?
        switch gene.type
          when NeuronType.sensory then n =
            new SensoryNeuron(text: gene.text, bias: gene.bias, id: gene.id)
          when NeuronType.output then n =
            new OutputNeuron(text: gene.text, bias: gene.bias, id: gene.id)
          when NeuronType.generic then n =
            new Neuron(text: gene.text, bias: gene.bias, id: gene.id)
        network.add(n)
      else if gene.weight?
        second_pass.push(gene)
    for gene in second_pass
      if network.isInNetworkByID(gene.to) and network.isInNetworkByID(gene.from)
        to = network.findInNetworkByID(gene.to)
        from = network.findInNetworkByID(gene.from)
        network.link(from, to, gene.weight)
    if not skip_prune
      network.prune(NeuronType.sensory, NeuronType.output)
    return network
  mutate: (options) ->
    changed = []
    sourceGenesByID = []
    destGenesByID = []
    hiddenLayerGenesByID = []
    routes_only = []
    pick_random = (arr) ->
      return arr[Math.floor(Math.random() * arr.length)]
    pick_random_index = (arr) ->
      return Math.floor(Math.random() * arr.length)
    update = (source, dest, hidden, routes, genome) ->
      for gene in genome
        if gene.id?
          if gene.type != NeuronType.output
            source.push(gene.id)
          if gene.type != NeuronType.sensory
            dest.push(gene.id)
          if gene.type != NeuronType.sensory and gene.type != NeuronType.output
            hidden.push(gene.id)
        if gene.weight?
          routes.push(gene)
    update(sourceGenesByID,
      destGenesByID,
      hiddenLayerGenesByID,
      routes_only,
      @genes)
    for gene, i in @genes
      if gene.weight?
        if Math.random() < options.weightchange.probability
          gene.weight += Math.nrandom() * options.weightchange.scale
          changed.push(i)
        if Math.random() < options.reroute.probability and
        destGenesByID.length > 1 and sourceGenesByID.length > 1
          original_to = gene.to
          original_from = gene.from
          if Math.random() < 0.5 # change to
            gene.to = pick_random((x for x in destGenesByID when x !=
            original_to))
          else # has the potential for circular references
            gene.from = pick_random((x for x in sourceGenesByID when x !=
            original_from))
          changed.push(i)
    if Math.random() < options.route_insertion.probability and
    routes_only.length > 0
      route_index = pick_random_index(routes_only)
      route = routes_only[route_index]
      tmp = new Neuron()
      @genes.push {id: tmp.id, text: tmp.text, type: tmp.type, bias: tmp.bias}
      changed.push(@genes.length - 1)
      tmp2 = route.to
      route.to = tmp.id
      @genes.push {
        weight: Neuron.generateRandomWeight(),
        from: tmp.id,
        to: tmp2
      }
      changed.push(@genes.length - 1)
      changed.push(route_index)
    if Math.random() < options.route_deletion.probability and
    routes_only.length > 0
      route = pick_random(routes_only)
      matched_indices =
      (i for x, i in @genes when x.weight == route.weight and
      x.to == route.to and x.from == route.from)
      for x in matched_indices
        @genes[x] = {empty: true}
        changed.push(x)
    if Math.random() < options.hiddenlayer_deletion.probability and
    hiddenLayerGenesByID.length > 0
      hidden_neuronid = pick_random(hiddenLayerGenesByID)
      hidden_neuron_index =
        (i for x, i in @genes when x.id == hidden_neuronid)[0]
      hidden_neuron_leaving = []
      hidden_neuron_arriving = []
      for x, i in @genes
        if x.from == hidden_neuronid
          hidden_neuron_leaving.push(x.to)
          @genes[i] = {empty: true}
          changed.push(i)
        if x.to == hidden_neuronid
          hidden_neuron_arriving.push(x.from)
          @genes[i] = {empty: true}
          changed.push(i)
      @genes[hidden_neuron_index] = {empty: true}
      changed.push(hidden_neuron_index)
      for a in hidden_neuron_arriving
        for l in hidden_neuron_leaving
          @genes.push({to: l, from: a, weight: Neuron.generateRandomWeight()})
          changed.push(@genes.length - 1)
    return changed

  clone: () ->
    extend(true, {}, @)

  equals: (other) ->
    return @differences(other) == 0

  differences: (other) ->
    closeTo = (x,y) -> Math.abs(x-y) < 0.000001
    differences = 0
    for gene, index in @genes
      if not (other.genes[index]? and
      ((gene.empty == other.genes[index].empty) or
      (gene.to == other.genes[index].to and
      gene.from == other.genes[index].from and
      closeTo(gene.weight, other.genes[index].weight)) or
      (closeTo(gene.bias, other.genes[index].bias) and
      gene.id == other.genes[index].id and
      gene.text == other.genes[index].text)))
        differences++
    return differences

root = module.exports ? this
root.Genome = Genome