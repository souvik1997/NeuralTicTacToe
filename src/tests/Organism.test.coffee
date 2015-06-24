Organism = require('../Organism').Organism
Genome = require('../Genome').Genome
describe = require('../JasmineShim').describe
describe 'Organism', ->
  it 'can initialize', ->
    x = new Organism(new Genome())
    expect(x).toBeDefined()
  it 'can have a fitness function', ->
    x = new Organism(new Genome())
    x.fitness = 10
    expect(x.fitness).toEqual(10)
  it 'can determine if an organism is of the same species', ->
    x = new Organism(new Genome())
    y = new Organism(new Genome())
    for a in [1..Organism.speciesThreshold-1]
      x.genome.genes.push({empty: true})
      expect(x.isOfSameSpeciesAs(y)).toBeTruthy()
    x.genome.genes.push({empty: true})
    expect(x.isOfSameSpeciesAs(y)).toBeFalsy()
  it 'can merge excess genes of two organisms with different
  fitness values', ->
    x = new Organism(new Genome())
    y = new Organism(new Genome())
    x.fitness = 10
    y.fitness = 11
    x.genome.genes.push({to: 2, from: 1, weight: 0.5})
    z = x.mate(y)
    expect(z.genome.genes.length).toEqual(0)
    x = new Organism(new Genome())
    y = new Organism(new Genome())
    x.fitness = 11
    y.fitness = 10
    x.genome.genes.push({to: 2, from: 1, weight: 0.5})
    z = x.mate(y)
    expect(z.genome.genes.length).toEqual(1)
  it 'can merge disjoint genes of two organisms with different
  fitness values', ->
    x = new Organism(new Genome())
    y = new Organism(new Genome())
    x.fitness = 10
    y.fitness = 11
    x.genome.genes.push({empty: true}, {to: 2, from: 1, weight: 0.5})
    y.genome.genes.push({to: 3, from: 2, weight: 0.6},
      {to: 2, from: 1, weight: 0.5})
    z = x.mate(y)
    expect(z.genome.genes.length).toEqual(2)
    expect(z.genome.genes[0]).toEqual({to: 3, from: 2, weight: 0.6})
    x = new Organism(new Genome())
    y = new Organism(new Genome())
    x.fitness = 11
    y.fitness = 10
    x.genome.genes.push({empty: true}, {to: 2, from: 1, weight: 0.5})
    y.genome.genes.push({to: 3, from: 2, weight: 0.6},
      {to: 2, from: 1, weight: 0.5})
    z = x.mate(y)
    expect(z.genome.genes.length).toEqual(2)
    expect(z.genome.genes[0]).toEqual({empty: true})
  it 'can merge different genes of two organisms with different
  fitness values', ->
    x = new Organism(new Genome())
    y = new Organism(new Genome())
    x.fitness = 10
    y.fitness = 11
    x.genome.genes.push({to: 2, from: 1, weight: 0.5})
    y.genome.genes.push({to: 3, from: 2, weight: 0.6})
    z = x.mate(y, {fitInheritanceProbability: 1})
    expect(z.genome.genes.length).toEqual(1)
    expect(z.genome.genes[0]).toEqual({to: 3, from: 2, weight: 0.6})
  it 'can mutate', ->
    x = new Organism(new Genome())
    y = new Organism(new Genome())
    x.fitness = 10
    y.fitness = 11
    x.genome.genes.push({to: 2, from: 1, weight: 0.5})
    y.genome.genes.push({to: 3, from: 2, weight: 0.6})
    z = x.mate(y, {
      fitInheritanceProbability: 1
      mutate:
        weightchange:
          probability: 0
          scale: 0
        reroute:
          probability: 0
        route_insertion:
          probability: 1
        route_deletion:
          probability: 0
        hiddenlayer_deletion:
          probability: 0
      })
    expect(z.genome.genes.length).toEqual(3)