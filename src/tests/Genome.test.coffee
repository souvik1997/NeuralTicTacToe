NeuralNetwork = require('../NeuralNetwork').NeuralNetwork
Neuron = require('../Neuron').Neuron
SensoryNeuron = require('../Neuron').SensoryNeuron
OutputNeuron = require('../Neuron').OutputNeuron
Genome = require('../Genome').Genome
NeuronType = require('../NeuronType').NeuronType
describe 'Genome', ->
  network = new NeuralNetwork()
  genome = new Genome()
  network.link(new Neuron("neuron_1", undefined, 1),
    new Neuron("neuron_2", undefined, 2), 0.2)
  genome.deconstruct(network)
  new_network = genome.construct()
  it 'can initialize', () ->
    expect(genome).toBeDefined()
  it 'can deconstruct a network', () ->
    expect(genome.genes[0].id).toEqual(1)
    expect(genome.genes[0].text).toEqual("neuron_1")
    expect(genome.genes[0].type).toEqual(NeuronType.generic)
    expect(genome.genes[1].id).toEqual(2)
    expect(genome.genes[1].text).toEqual("neuron_2")
    expect(genome.genes[1].type).toEqual(NeuronType.generic)
    expect(genome.genes[2].weight).toEqual(0.2)
    expect(genome.genes[2].to).toEqual(2)
    expect(genome.genes[2].from).toEqual(1)
  it 'can construct all neurons in a new network', () ->
    for n in new_network.neurons
      expect(network.isInNetworkByID(n.id)).toBeTruthy()
  it 'can construct all paths in a new network', () ->
    for n in new_network.neurons
      for m in network.findInNetwork(n).dendrites
        expect(n.hasDendrite(m.neuron)).toBeTruthy()
  it 'can mutate (weight)', () ->
    genome = new Genome()
    network = new NeuralNetwork()
    network.add(new SensoryNeuron("neuron 3", undefined, 3))
    genome.deconstruct(network)
    changed = genome.mutate({
      weightchange: {
        probability: 1
        scale: 1000
      },
      reroute: {
        probability: 0
      },
      route_insertion: {
        probability: 0
      },
      route_deletion: {
        probability: 0
      },
      hiddenlayer_deletion: {
        probability: 0
      }
    })
    expect(changed.length).toEqual(0)
    network.link(network.findInNetworkByID(3),
      new Neuron("neuron 4", undefined, 4))
    genome.deconstruct(network)
    changed = genome.mutate({
      weightchange: {
        probability: 1
        scale: 1000
      },
      reroute: {
        probability: 0
      },
      route_insertion: {
        probability: 0
      },
      route_deletion: {
        probability: 0
      },
      hiddenlayer_deletion: {
        probability: 0
      }
    })
    expect(changed.length).toEqual(1)
    expect(genome.genes[changed[0]].weight != 0).toBeTruthy()
  it 'can mutate (reroute)', () ->
    network.link(network.findInNetworkByID(4),
      new OutputNeuron("neuron 5", undefined, 5))
    genome.deconstruct(network)
    changed = genome.mutate({
      weightchange: {
        probability: 0
        scale: 0
      },
      reroute: {
        probability: 1
      },
      route_insertion: {
        probability: 0
      },
      route_deletion: {
        probability: 0
      },
      hiddenlayer_deletion: {
        probability: 0
      }
    })
    expect(changed.length).toEqual(2)
    expect((genome.genes[changed[0]].to != 3 or
        genome.genes[changed[0]].from != 4) and
        (genome.genes[changed[1]].to != 4 or
        genome.genes[changed[1]].from != 5)).toBeTruthy()
  it 'can mutate (route insertion)', () ->
    network = new NeuralNetwork()
    network.link(new SensoryNeuron("SensoryNeuron 1", undefined, 1),
      new OutputNeuron("OutputNeuron 1", undefined, 2))
    genome.deconstruct(network)
    changed = genome.mutate({
      weightchange: {
        probability: 0
        scale: 0
      },
      reroute: {
        probability: 0
      },
      route_insertion: {
        probability: 1
      },
      route_deletion: {
        probability: 0
      },
      hiddenlayer_deletion: {
        probability: 0
      }
    })
    expect((x for x in genome.genes when x.weight?).length).toBeGreaterThan(1)
  it 'can mutate (route deletion)', () ->
    genome.deconstruct(network)
    original_length = genome.genes.length
    changed = genome.mutate({
      weightchange: {
        probability: 0
        scale: 0
      },
      reroute: {
        probability: 0
      },
      route_insertion: {
        probability: 0
      },
      route_deletion: {
        probability: 1
      },
      hiddenlayer_deletion: {
        probability: 0
      }
    })
    expect(changed.length).toEqual(1)
    expect(genome.genes[changed[0]]).toEqual({empty: true})
  it 'can mutate (hidden layer deletion)', () ->
    network = new NeuralNetwork()
    sense_1 = new SensoryNeuron("", undefined, 1)
    sense_2 = new SensoryNeuron("", undefined, 2)
    hidden_3 = new Neuron("", undefined, 3)
    output_4 = new OutputNeuron("", undefined, 4)
    output_5 = new OutputNeuron("", undefined, 5)
    network.link(sense_1, hidden_3)
    network.link(sense_2, hidden_3)
    network.link(hidden_3, output_4)
    network.link(hidden_3, output_5)
    genome.deconstruct(network)
    changed = genome.mutate({
      weightchange: {
        probability: 0
        scale: 0
      },
      reroute: {
        probability: 0
      },
      route_insertion: {
        probability: 0
      },
      route_deletion: {
        probability: 0
      },
      hiddenlayer_deletion: {
        probability: 1
      }
    })
    expect(changed.length).toEqual(9)
