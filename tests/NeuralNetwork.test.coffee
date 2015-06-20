describe 'NeuralNetwork', ->
  network = new NeuralNetwork(new Neuron())
  endNode = new Neuron()
  beginningNode = new Neuron()
  network.linkToEnd(network.root, endNode, 0.1)
  network.linkToStart(beginningNode, network.root, 0.1)
  it 'can initialize', () ->
    expect(network).toBeDefined()
  it 'can add to end', () ->
    expect(endNode.isADendrite network.root).toBeTruthy()
  it 'can add to start', () ->
    expect(network.root.isADendrite beginningNode).toBeTruthy()
  it 'can insert', () ->
    insertedNode = new Neuron()
    network.insert(beginningNode, insertedNode, network.root)
    expect(insertedNode.isADendrite beginningNode).toBeTruthy()
    expect(network.root.isADendrite insertedNode).toBeTruthy()
  it 'can remove a neuron from one parent', () ->
    network.unlinkEnd(network.root, endNode)
    expect(endNode.isADendrite network.root).toBeFalsy()
  it 'can completely unlink a neuron', () ->
    network.linkToEnd(network.root, endNode, 0.1)
    network.linkToStart(endNode, beginningNode, 0.1)
    expect(beginningNode.isADendrite endNode).toBeTruthy()
    expect(endNode.isADendrite network.root).toBeTruthy()
    network.unlinkFromAll(endNode)
    expect(beginningNode.isADendrite endNode).toBeFalsy()
    expect(endNode.isADendrite network.root).toBeFalsy()
  it 'can delete a neuron', () ->
    original = network.neurons.length
    network.delete(network.findInNetwork beginningNode)
    expect(network.neurons.length).toEqual(original - 1)
  
