Math.nrandom = () ->
  ((Math.random() + Math.random() + Math.random() +
  Math.random() + Math.random() + Math.random() +
  Math.random() + Math.random() + Math.random() +
  Math.random() + Math.random() + Math.random()) / 12) - 0.5

Math.sigmoid = (t) ->
  1/(1+Math.exp(-t))

Math.dsigmoid = (t) ->
  Math.sigmoid(t) * (1- Math.sigmoid(t))

root = module.exports ? this
root.Math = Math