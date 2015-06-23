Genome = require('./Genome').Genome
Math = require('./MathPolyfill').Math
class Organism
  constructor: (genome) ->
    @genome = genome

  isOfSameSpeciesAs: (other) ->
    if other.genome.genes.length > @genome.genes.length
      return other.genome.differences(@genome) < Organism.speciesThreshold
    return @genome.differences(other.genome) < Organism.speciesThreshold

  calculateFitness: (fitnessFunction) ->
    if fitnessFunction? and typeof(fitnessFunction) == "function"
      @fitness = fitnessFunction()

  mate: (other, options={}) ->
    if @isOfSameSpeciesAs(other)
      other_clone = other.genome.clone()
      my_clone = @genome.clone()
      newgenome =
        if @fitness > other.fitness then my_clone else other_clone
      other_is_longer = other_clone.genes.length > my_clone.genes.length
      # differences should be in both genomes
      differences =
        (if other_is_longer then my_clone.differences(other_clone) else
        other_clone.differences(my_clone))
      for gene_index in differences
        if other_clone.genes[gene_index].empty? or
        my_clone.genes[gene_index].empty?
          continue # disjoint genes should be inherited from the more fit parent
        if @fitness > other.fitness
          newgenome[gene_index] =
            (if Math.random() < options.fitInheritanceProbability
            then my_clone[gene_index] else
            other.genome[gene_index])
      if not options.mutate?
        return new Organism(newgenome)
      newgenome.mutate(options.mutate)
      return new Organism(newgenome)


Organism.speciesThreshold = 10
root = module.exports ? this
root.Organism = Organism