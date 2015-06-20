NeuralNetwork = require('../NeuralNetwork').NeuralNetwork
Neuron = require('../Neuron').Neuron
describe 'NeuralNetwork', ->
  network = new NeuralNetwork()
  rootNode = new Neuron()
  network.add(rootNode)
  endNode = new Neuron()
  beginningNode = new Neuron()
  network.linkToEnd(rootNode, endNode, 0.1)
  network.linkToStart(beginningNode, rootNode, 0.1)
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
    network.unlinkEnd(rootNode, endNode)
    expect(endNode.hasDendrite rootNode).toBeFalsy()
  it 'can completely unlink a neuron', () ->
    network.linkToEnd(rootNode, endNode, 0.1)
    network.linkToStart(endNode, beginningNode, 0.1)
    expect(beginningNode.hasDendrite endNode).toBeTruthy()
    expect(endNode.hasDendrite rootNode).toBeTruthy()
    network.unlinkFromAll(endNode)
    expect(beginningNode.hasDendrite endNode).toBeFalsy()
    expect(endNode.hasDendrite rootNode).toBeFalsy()
  it 'can clone itself', () ->
    new_network = network.clone()
    expect(new_network.neurons[0]).toEqual(rootNode)
    new_network.neurons[0] = new Neuron()
    expect(new_network.neurons[0].equals(rootNode)).toBeFalsy()
  
  
