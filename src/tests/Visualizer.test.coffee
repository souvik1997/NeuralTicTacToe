NeuralNetwork = require('../NeuralNetwork').NeuralNetwork
Neuron = require('../Neuron').Neuron
SensoryNeuron = require('../Neuron').SensoryNeuron
OutputNeuron = require('../Neuron').OutputNeuron
NeuronType = require('../NeuronType').NeuronType
Visualizer = require('../Visualizer').Visualizer
Math = require('../MathPolyfill').Math
describe = require('../JasmineShim').describe
describe 'Visualizer', ->
  network = new NeuralNetwork()
  rootNode = new Neuron()
  network.add(rootNode)
  endNode = new OutputNeuron()
  beginningNode = new SensoryNeuron()
  network.link(rootNode, endNode, 0.1)
  network.link(beginningNode, rootNode, 0.1)
  visualizer = new Visualizer(null, network)
  visualizer.createNodesAndEdges()
  it 'can initialize', () ->
    expect(visualizer).toBeDefined()
  it 'can create nodes', () ->
    expect(visualizer.nodes.length).toEqual(3)
  it 'can create edges', () ->
    expect(visualizer.edges.length).toEqual(2)
  it 'can appropriately assign values to edges', () ->
    expect(visualizer.edges[0].value).toEqual(Math.sigmoid(0.1))
  it 'can appropriately color generic neurons', () ->
    expect(visualizer.nodes[0].color).toEqual(
      visualizer.settings[NeuronType.generic])
  it 'can appropriately color output neurons', () ->
    expect(visualizer.nodes[1].color).toEqual(
      visualizer.settings[NeuronType.output])
  it 'can appropriately color sensory neurons', () ->
    expect(visualizer.nodes[2].color).toEqual(
      visualizer.settings[NeuronType.sensory])
  
  
