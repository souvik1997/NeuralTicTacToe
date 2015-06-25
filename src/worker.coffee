Trainer = require('./Trainer').Trainer
Genome = require("./Genome").Genome
module.exports = (self) ->
  self.addEventListener 'message', (e) ->
    _genome = new Genome()
    _genome.genes = e.data.genome.genes
    network = _genome.construct()
    trainer = new Trainer(network)
    trainer.train(1)
    _genome = new Genome()
    _genome.deconstruct(trainer.network)
    postMessage({genome: _genome})
