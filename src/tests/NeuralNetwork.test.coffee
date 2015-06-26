NeuralNetwork = require('../NeuralNetwork').NeuralNetwork
Neuron = require('../Neuron').Neuron
SensoryNeuron = require('../Neuron').SensoryNeuron
NeuronType = require('../NeuronType').NeuronType
OutputNeuron = require('../Neuron').OutputNeuron
describe = require('../JasmineShim').describe
describe 'NeuralNetwork', ->
  network = new NeuralNetwork()
  rootNode = new Neuron()
  network.add(rootNode)
  endNode = new Neuron()
  beginningNode = new Neuron()
  network.link(rootNode, endNode, 0.1)
  network.link(beginningNode, rootNode, 0.1)
  it 'can initialize', () ->
    expect(network).toBeDefined()
  it 'can add to end', () ->
    expect(endNode.hasDendrite rootNode).toBeTruthy()
  it 'can add to start', () ->
    expect(rootNode.hasDendrite beginningNode).toBeTruthy()
  it 'can insert', () ->
    insertedNode = new Neuron()
    network.insert(beginningNode, insertedNode, rootNode)
    expect(insertedNode.hasDendrite beginningNode).toBeTruthy()
    expect(rootNode.hasDendrite insertedNode).toBeTruthy()
  it 'can remove a neuron from one parent', () ->
    network.unlink(rootNode, endNode)
    expect(endNode.hasDendrite rootNode).toBeFalsy()
  it 'can completely unlink a neuron', () ->
    network = new NeuralNetwork()
    rootNode = new Neuron()
    endNode = new Neuron()
    beginningNode = new Neuron()
    network.link(rootNode, endNode, 0.1)
    network.link(endNode, beginningNode, 0.1)
    expect(beginningNode.hasDendrite endNode).toBeTruthy()
    expect(endNode.hasDendrite rootNode).toBeTruthy()
    network.unlinkFromAll(endNode)
    expect(beginningNode.hasDendrite endNode).toBeFalsy()
    expect(endNode.hasDendrite rootNode).toBeFalsy()
  it 'can clone itself', () ->
    new_network = network.clone()
    expect(new_network.neurons[0].equals(rootNode)).toBeTruthy()
    new_network.neurons[0] = new Neuron()
    expect(new_network.neurons[0].equals(rootNode)).toBeFalsy()
  it 'can search for neurons', () ->
    expect(network.findInNetwork(rootNode)).toBeDefined()
    expect(network.findInNetwork(rootNode).equals(rootNode)).toBeTruthy()
    expect(network.findInNetworkByID(rootNode.id)
      .equals(rootNode)).toBeTruthy()
  it 'can check for circular references', () -> # actual network is not needed
    n1 = new Neuron(id: 123)
    n2 = new Neuron(id: 456)
    n3 = new Neuron(id: 789)
    n1.addDendrite(n2,1)
    n2.addDendrite(n3,1)
    expect(network.checkCircularReference(n3,n1)).toBeTruthy()
    expect(network.checkCircularReference(n3, new Neuron())).toBeFalsy()
    n3.addDendrite(n1)
    expect(network.checkCircularReference(n3,new Neuron())).toBeTruthy()
    network = new NeuralNetwork()
    first_hidden_layer = []
    second_hidden_layer = []
    third_hidden_layer = []
    for x in [0..3]
      first_hidden_layer.push(new Neuron())
      second_hidden_layer.push(new Neuron())
      third_hidden_layer.push(new Neuron())

    sensory_neurons = []
    output_neurons = []
    for x in [0..2]
      for y in [0..2]
        sensory_neurons.push new SensoryNeuron(text: "("+x+","+y+")")
        output_neurons.push new OutputNeuron(text: "("+x+","+y+")")
    for first in first_hidden_layer
      for second in second_hidden_layer
        network.link(first, second)
    for second in second_hidden_layer
      for third in third_hidden_layer
        network.link(second, third)
    for neuron in sensory_neurons
      for first in first_hidden_layer
        network.link(neuron, first)
    for neuron in output_neurons
      for third in third_hidden_layer
        network.link(third, neuron)
    expect(network.neurons.length).toEqual(9+9+4+4+4)
  it 'can prune the network of unlinked neurons', () ->
    network_1 = new NeuralNetwork()
    network_1.link(new SensoryNeuron(), new OutputNeuron())
    network_1.add(new Neuron())
    expect(network_1.neurons.length).toEqual(3)
    network_1.prune()
    expect(network_1.neurons.length).toEqual(2)
    network_2 = new NeuralNetwork()
    network_2.link(new SensoryNeuron(), new OutputNeuron())
    network_2.add(new Neuron())
    network_2.add(new SensoryNeuron())
    expect(network_2.neurons.length).toEqual(4)
    network_2.prune(NeuronType.sensory)
    expect(network_2.neurons.length).toEqual(3)
    network_3 = new NeuralNetwork()
    network_3.link(new Neuron(), new Neuron())
    expect(network_3.neurons.length).toEqual(2)
    network_3.prune()
    expect(network_3.neurons.length).toEqual(2)
  it 'can create a new network from existing data', () ->
    network_1 = new NeuralNetwork()
    network_1.link(new SensoryNeuron(), new OutputNeuron())
    network_1.add(new Neuron())
    expect(network_1.neurons.length).toEqual(3)
    data = JSON.parse JSON.stringify network_1
    expect(data.add).not.toBeDefined()
    network_2 = NeuralNetwork.fromArray(data)
    expect(network_1).toEqual(network_2)