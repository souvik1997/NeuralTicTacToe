NeuronType = require('./NeuronType').NeuronType
Math = require('./MathPolyfill').Math
class Neuron
  constructor: (text, id) ->
    @_initialize(text, id)
    @type = NeuronType.generic

  _initialize: (text, id) ->
    @dendrites = new Array()
    @events = new Array()
    @id = id ? Math.round Math.random() * 1000000
    @text = text

  addDendrite: (target_neuron, weight) ->
    if not @hasDendrite(target_neuron) and not target_neuron.equals @
      @dendrites.push { weight: weight, neuron: target_neuron}

  removeDendrite: (arg) ->
    if arg >= 0
      @dendrites.splice arg, 1

  getDendrite: (index) ->
    return @dendrites[index]

  getDendrites: (index) ->
    return @dendrites

  clearDendrites: () ->
    @dendrites = []

  findDendrite: (neuron) ->
    return (i for o, i in @dendrites when o.neuron.equals(neuron))[0] ? -1

  hasDendrite: (neuron) ->
    return @findDendrite(neuron) != -1

  getOutput: ->
    if @dendrites.length != 0
      value = (x.weight * x.neuron.getOutput() for x in @dendrites)
        .reduce((a,b) -> a+b)
    if @events['fire']? and typeof @events['fire'] is "function"
      @events['fire'](value)
    return value

  equals: (neuron) ->
    return @id is neuron.id

  on: (event, callback) ->
    @events[event] = callback

class SensoryNeuron extends Neuron
  constructor: (text, id)->
    @_initialize(text, id)
    @type = NeuronType.sensory
  getOutput: ->
    if @dendrites.length is 0
      if @events['sense']? and typeof @events['sense'] is "function"
        value = @events['sense']()
      else
        value = 0
    else
      value = (x.weight * x.neuron.getOutput() for x in @dendrites)
        .reduce((a,b) -> a+b)
    if @events['fire']? and typeof @events['fire'] is "function"
      @events['fire'](value)
    return value

class OutputNeuron extends Neuron
  constructor: (text, id) ->
    @_initialize(text, id)
    @type = NeuronType.output

Neuron.generateRandomWeight = () ->
  Math.nrandom() * 10

root = module.exports ? this
root.Neuron = Neuron
root.SensoryNeuron = SensoryNeuron
root.OutputNeuron = OutputNeuron

