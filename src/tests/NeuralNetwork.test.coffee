NeuralNetwork = require('../NeuralNetwork').NeuralNetwork
Neuron = require('../Neuron').Neuron
describe 'NeuralNetwork', ->
  network = new NeuralNetwork(new Neuron())
  endNode = new Neuron()
  beginningNode = new Neuron()
  network.linkToEnd(network.root, endNode, 0.1)
  network.linkToStart(beginningNode, network.root, 0.1)
  it 'can initialize', () ->
    expect(network).toBeDefined()
  it 'can add to end', () ->
    expect(endNode.hasDendrite network.root).toBeTruthy()
  it 'can add to start', () ->
    expect(network.root.hasDendrite beginningNode).toBeTruthy()
  it 'can insert', () ->
    insertedNode = new Neuron()
    network.insert(beginningNode, insertedNode, network.root)
    expect(insertedNode.hasDendrite beginningNode).toBeTruthy()
    expect(network.root.hasDendrite insertedNode).toBeTruthy()
  it 'can remove a neuron from one parent', () ->
    network.unlinkEnd(network.root, endNode)
    expect(endNode.hasDendrite network.root).toBeFalsy()
  it 'can completely unlink a neuron', () ->
    network.linkToEnd(network.root, endNode, 0.1)
    network.linkToStart(endNode, beginningNode, 0.1)
    expect(beginningNode.hasDendrite endNode).toBeTruthy()
    expect(endNode.hasDendrite network.root).toBeTruthy()
    network.unlinkFromAll(endNode)
    expect(beginningNode.hasDendrite endNode).toBeFalsy()
    expect(endNode.hasDendrite network.root).toBeFalsy()
  
  
