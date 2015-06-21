Math.nrandom = () ->
  ((Math.random() + Math.random() + Math.random() +
  Math.random() + Math.random() + Math.random() +
  Math.random() + Math.random() + Math.random() +
  Math.random() + Math.random() + Math.random()) / 12) - 0.5

Math.sigmoid = (t) ->
  1/(1+exp(-t))

root = module.exports ? this
root.Math = Math