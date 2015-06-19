class Neuron
	axonTerminals = []
	events = []
	_id = Math.round Math.random() * 1000000;
	addConnection: (weight, target_neuron) ->
		axonTerminals.push { weight: weight, neuron: target_neuron}
	receive: ->
		if events['receive']? and typeof events['receive'] is "function"
			events['receive']()
		sum = 0
		sum += x.weight for x in axonTerminals;
		target = Math.round Math.random() * sum;
		cumulativeWeight = 0
		for [weight, neuron] in axonTerminals
			cumulativeWeight += weight
			if cumulativeWeight > target
				neuron.receive()
				return
	equals: (neuron) ->
		return _id is neuron._id
	removeConnection: (arg) ->
		if typeof arg is "number"
			axonTerminals.splice arg, 1
		else if typeof arg is "object"
			index = (i for o, i in axonTerminals when o.equals(arg))
			removeConnection index
		return
	getConnection: (index) ->
		return axonTerminals[index]
	on: (event, callback) ->
		events[event] = callback

root = exports ? this
root.Neuron = Neuron