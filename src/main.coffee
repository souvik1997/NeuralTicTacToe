jQuery = require('jquery')
Neuron = require('./Neuron').Neuron
SensoryNeuron = require('./Neuron').SensoryNeuron
OutputNeuron = require('./Neuron').OutputNeuron
Visualizer = require('./Visualizer').Visualizer
NeuralNetwork = require('./NeuralNetwork').NeuralNetwork
Genome = require('./Genome').Genome
TicTacToe = require('./TicTacToe').TicTacToe
RandomTicTacToePlayer = require('./RandomTicTacToePlayer').RandomTicTacToePlayer
Organism = require('./Organism').Organism
Math = require('./MathPolyfill').Math
if window?
  window.$ = window.jQuery = jQuery
  Bootstrap = require('bootstrap/dist/js/npm')

jQuery(() ->
  container = $("#mynetwork")[0]
  @visualizer = new Visualizer(container, {
    physics:
      timestep: 0.1
    height: "60%"
  })
  @network = new NeuralNetwork()
  console.log "initializing"

  $("#modal-toggle").click( =>
    $("#mymodal").modal({show: true, backdrop: 'static', keyboard: false})
    if @visualizer
      @visualizer.draw(@network)
  )
  $("#modal-close").click( =>
    $("#mymodal").modal('hide')
    if @visualizer
      @visualizer.destroy()
  )
  @TicTacToe = new TicTacToe()
  @currentPlayer = TicTacToe.player.X
  playerO = new RandomTicTacToePlayer(@TicTacToe, TicTacToe.player.O)
  # Set up events for tic tac toe buttons
  updateGrid = (r, c) =>
    $("#i#{r}#{c}").html(
      if @currentPlayer == TicTacToe.player.X then "&#x2715;"
      else if @currentPlayer == TicTacToe.player.O then "O"
      else "&nbsp;"
    )
  showState = () =>
    result = @TicTacToe.state
    if result == TicTacToe.state.draw
      $(".tic-tac-toe-notification").html("Draw!")
      $(".tic-tac-toe-end").show()
    else if result == TicTacToe.state.xWin
      $(".tic-tac-toe-notification").html("X wins!")
      $(".tic-tac-toe-end").show()
    else if result == TicTacToe.state.oWin
      $(".tic-tac-toe-notification").html("O wins!")
      $(".tic-tac-toe-end").show()
    return result

  $("#restart-btn").click(() =>
    @TicTacToe.newGame()
    @currentPlayer = TicTacToe.player.X
    for r in [0..2]
      for c in [0..2]
        $("#i#{r}#{c}").html("&nbsp;")
    $(".tic-tac-toe-end").hide()
  )
  for r in [0..2]
    for c in [0..2]
      do (r, c) =>
        console.log "Event #i#{r}#{c}"
        $("#i#{r}#{c}").click(() =>
          console.log "Clicked #{r}#{c}"
          if @TicTacToe.getPlayerAt(r, c) == TicTacToe.player.empty
            result = @TicTacToe.move(r, c, @currentPlayer)
            updateGrid(r, c)
            result = showState()
            if result == TicTacToe.state.inProgress
              @currentPlayer =
                (if @currentPlayer == TicTacToe.player.X then TicTacToe.player.O
                else TicTacToe.player.X)
              move = playerO.move()
              updateGrid(move.r, move.c)
              showState()
              @currentPlayer =
                (if @currentPlayer == TicTacToe.player.X then TicTacToe.player.O
                else TicTacToe.player.X)
        )
  # Actual simulation code
  interval = (time, fn) -> setInterval(fn, time)
  sensory_neurons = []
  output_neurons = []
  for r in [0..2]
    for c in [0..2]
      sensory_neurons.push new SensoryNeuron(
        text: "("+r+","+c+")",
        id:10+r+c/10)
      output_neurons.push new OutputNeuron(
        text: "("+r+","+c+")",
        id:20+r+c/10)
  for s in sensory_neurons
    for o in output_neurons
      @network.link(s, o)
  getMutationOptions = (k) -> {
    fitInheritanceProbability: 0.666
    mutate:
      weightchange:
        probability: 0.5 * k
        scale: 10
      reroute:
        probability: 0.5 * k
      route_insertion:
        probability: 0.5 * k
      route_deletion:
        probability: 0.5 * k
      hiddenlayer_deletion:
        probability: 0.5 * k
    }
  getStats = (organism) ->
    o_network = organism.genome.construct()
    game = new TicTacToe()
    if Math.random() < 0.5
      network_player = TicTacToe.player.X
      random_player = TicTacToe.player.O
    else
      network_player = TicTacToe.player.O
      random_player = TicTacToe.player.X
    for r in [0..2]
      for c in [0..2]
        sensory_id = 10+r+c/10
        do (r,c) ->
          sensor = o_network.findInNetworkByID(sensory_id)
          if sensor != -1
            sensor.on('sense', ->
              player = game.getPlayerAt(r, c)
              if player == network_player
                return 1
              if player == random_player
                return -1
              return 0
            )
    stats = {
      wins: 0
      losses: 0
      draws: 0
    }
    currentPlayer = TicTacToe.player.X
    for x in [0..1000]
      randomTTTPlayer = new RandomTicTacToePlayer(game, random_player)
      while game.state == TicTacToe.state.inProgress
        if random_player == currentPlayer
          randomTTTPlayer.move()
        else if network_player == currentPlayer
          moves = []
          for r in [0..2]
            for c in [0..2]
              if game.getPlayerAt(r, c) == TicTacToe.player.empty
                output_id = 20+r+c/10
                output = o_network.findInNetworkByID(output_id)
                if output != -1
                  moves.push({
                    priority: output.getOutput()
                    r: r
                    c: c
                  })
                moves.sort((a,b) -> b.priority - a.priority)
                game.move(moves[0].r, moves[0].c, network_player)
        if (game.state == TicTacToe.state.xWin and
        network_player == TicTacToe.player.X) or
        (game.state == TicTacToe.state.oWin and
        network_player == TicTacToe.player.O)
          stats.wins++
        else if game.state == TicTacToe.state.draw
          stats.draws++
        else if game.state != TicTacToe.state.inProgress
          stats.losses++
        currentPlayer =
          (if currentPlayer == TicTacToe.player.X then TicTacToe.player.O
          else TicTacToe.player.X)
      game.newGame()
    return stats




  ancestral_genome = new Genome()
  ancestral_genome.deconstruct(@network)
  ancestor = new Organism(ancestral_genome)
  generations = []
  generations[0] = []
  for x in [0..50]
    child = ancestor.mate(ancestor,getMutationOptions(1))
    stats = getStats(child)
    child.fitness = 10*stats.wins+2*stats.draws-15*stats.losses
    console.log JSON.stringify stats

)