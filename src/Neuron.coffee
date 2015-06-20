class Neuron
  constructor: () ->
    @dendrites = new Array()
    @events = new Array()
    @_id = Math.round Math.random() * 1000000

  addDendrite: (target_neuron, weight) ->
    if not @isADendrite(target_neuron) and not target_neuron.equals @
      @dendrites.push { weight: weight, neuron: target_neuron}

  removeDendrite: (index) ->
    if index >= 0
      @dendrites.splice index, 1

  getDendrite: (index) ->
    return @dendrites[index]

  clearDendrites: () ->
    @dendrites = []

  findDendrite: (neuron) ->
    return (i for o, i in @dendrites when o.neuron.equals(neuron))[0] ? -1

  isADendrite: (neuron) ->
    return @findDendrite(neuron) != -1

  getOutput: ->
    if @dendrites.length is 0
      if @events['sense']? and typeof @events['sense'] is "function"
        value = @events['sense']
      else
        value = 0
    else
      value = (x.weight * x.neuron.getOutput() for x in @dendrites)
        .reduce((a,b) -> a+b)
    if @events['fire']? and typeof @events['fire'] is "function"
      @events['fire']()
    return value

  equals: (neuron) ->
    return @_id is neuron._id

  on: (event, callback) ->
    @events[event] = callback

root = exports ? this
root.Neuron = Neuron