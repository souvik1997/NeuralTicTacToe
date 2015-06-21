Neuron = require('../Neuron').Neuron
SensoryNeuron = require('../Neuron').SensoryNeuron
OutputNeuron = require('../Neuron').OutputNeuron
NeuronType = require('../NeuronType').NeuronType
describe 'Neuron', ->
  first_neuron = new Neuron()
  second_neuron = new Neuron()
  second_neuron.addDendrite(first_neuron, 0.3)
  it 'can initialize', () ->
    expect(first_neuron).toBeDefined()
  it 'has the right neuron type', () ->
    expect(first_neuron.type).toEqual(NeuronType.generic)
  it 'can add new neurons to network', () ->
    expect(second_neuron.getDendrite(0).weight).toBe(0.3)
  it 'can have events', () ->
    spyObj =
      callback: () ->
        return
    spyOn(spyObj,'callback')
    first_neuron.on('fire', spyObj.callback)
    second_neuron.getOutput()
    expect(spyObj.callback).toHaveBeenCalled()
  it 'can search for neurons', () ->
    expect(second_neuron.findDendrite(first_neuron)).toEqual(0)
    expect(second_neuron.hasDendrite(first_neuron)).toBeTruthy()
  it 'can remove neurons', () ->
    second_neuron.removeDendrite(0)
    expect(second_neuron.getDendrite(0)).toEqual(undefined)
  it 'can have a set ID', () ->
    test = new Neuron(id: -1)
    expect(test.id).toEqual(-1)
  it 'can have a random ID', () ->
    test = new Neuron()
    expect(test.id).toBeDefined()
    expect(test.id).toBeGreaterThan(-1)
  it 'can have a set bias', () ->
    test = new Neuron(bias: 10000000000)
    expect(test.bias).toEqual(10000000000)
  it 'can have a random bias', () ->
    test = new Neuron()
    expect(test.bias).toBeDefined()
    expect(test.id).toBeGreaterThan(-1)

describe 'SensoryNeuron', ->
  sensory_neuron = new SensoryNeuron()
  it 'can initialize', () ->
    expect(sensory_neuron).toBeDefined()
  it 'has the right neuron type', () ->
    expect(sensory_neuron.type).toEqual(NeuronType.sensory)
  it 'can have a sensory function', () ->
    spyObj =
      callback: () ->
        return
    spyOn(spyObj,'callback')
    sensory_neuron.on('sense', spyObj.callback)
    sensory_neuron.getOutput()
    expect(spyObj.callback).toHaveBeenCalled()

describe 'OutputNeuron', ->
  output_neuron = new OutputNeuron()
  it 'can initialize', () ->
    expect(output_neuron).toBeDefined()
  it 'has the right neuron type', () ->
    expect(output_neuron.type).toEqual(NeuronType.output)