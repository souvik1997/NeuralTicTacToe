describe 'Neuron', ->
  first_neuron = new Neuron()
  second_neuron = new Neuron()
  second_neuron.addDendrite(first_neuron, 0.3)
  it 'can initialize', () ->
    expect(first_neuron).toBeDefined()
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
  it 'can remove neurons', () ->
    second_neuron.removeDendrite(0)
    expect(second_neuron.getDendrite(0)).toEqual(undefined)
