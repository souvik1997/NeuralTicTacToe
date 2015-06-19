class @Neuron
	axonTerminals = []
	@_id = Math.round Math.random() * 1000000;

Neuron::receive = ->
	if @onEvent? and typeof onEvent is "function"
		onEvent()
	sum = 0
	sum += x[0] for x in @axonTerminals;
	target = Math.round Math.random() * sum;
	cumulativeWeight = 0
	for [weight, neuron] in @axonTerminals
		cumulativeWeight += weight
		if cumulativeWeight > target
			neuron.receive()
			return

Neuron::equals = (neuron) ->
	return @_id is neuron._id
	
Neuron::addConnection = (weight, neuron) ->
	@axonTerminals.push [weight, neuron]
	
Neuron::removeConnection = (arg) ->
	if typeof arg is "number"
		@axonTerminals.splice arg, 1
	else if typeof arg is "object"
		index = (i for o, i in @axonTerminals when o.equals(arg))
		@removeConnection index
	return

exports.Neuron = Neuron