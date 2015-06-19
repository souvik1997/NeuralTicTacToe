describe 'Neuron', ->
	neuron = null
	neuron = new Neuron();
	neuron.addConnection(10, new Neuron())
	it 'can initialize', () ->
		expect(neuron).toBeDefined()
	it 'can add new neurons to network', () ->		
		expect(neuron.getConnection(0).weight).toBe(10)
	it 'can have events', () ->
		spyObj = 
				callback: () -> 
					return;
		spyOn(spyObj,'callback')
		neuron.on('receive', spyObj.callback)
		neuron.receive();
		expect(spyObj.callback).toHaveBeenCalled();
	it 'can remove neurons', () ->
		neuron.removeConnection(0)
		expect(neuron.getConnection(0)).toBe(undefined)
