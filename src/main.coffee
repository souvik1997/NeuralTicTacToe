Neuron = require('./Neuron').Neuron
SensoryNeuron = require('./Neuron').SensoryNeuron
OutputNeuron = require('./Neuron').OutputNeuron
Visualizer = require('./Visualizer').Visualizer
NeuralNetwork = require('./NeuralNetwork').NeuralNetwork
Genome = require('./Genome').Genome
TicTacToe = require('./TicTacToe').TicTacToe
RandomTicTacToePlayer = require('./RandomTicTacToePlayer').RandomTicTacToePlayer
NeuralTicTacToePlayer = require('./NeuralTicTacToePlayer').NeuralTicTacToePlayer
Organism = require('./Organism').Organism
Math = require('./MathPolyfill').Math
JasmineEnabled = require('./JasmineShim').jasmineEnabled
Work = require('webworkify')
statistics = require('simple-statistics')
if not window? or not window.Worker? or JasmineEnabled
  return
window.$ = window.jQuery = jQuery = require('jquery')
require('bootstrap/dist/js/npm')
require('highcharts-release/highcharts.src.js')
require('highcharts-release/highcharts-more.src.js')
jQuery(() ->
  network = new NeuralNetwork()
  trainerEnabled = false
  numberOfGenerationsSimulated = 0
  training_options =
  {
    fitInheritanceProbability: 1
    numToCreate: 20
    gamesToPlay: 20
    target: 4000
    randomPlayerDifficulty: -10
    weight:
      win: 10
      draw: 0
      loss: -10
    mutate:
      weightchange:
        probability: 0.9
        scale: 10
      reroute:
        probability: 0.8
      route_insertion:
        probability: 0.8
      route_deletion:
        probability: 0
      hiddenlayer_deletion:
        probability: 0
  }
  fitness_boxplot_chart = new Highcharts.Chart(
    {
      chart:
        type: "boxplot"
        zoomType: "x"
        animation: Highcharts.svg
        renderTo: "fitness-boxplot-chart"
      title:
        text: "Fitness vs. Generation"
      xAxis:
        text: "Generation"
        allowDecimals: false
        labels:
          formatter: () ->
            return @value
      yAxis:
        text: "Fitness"
      series:
        [{
          name: "Fitness"
        }]
    },
  )
  wdl_current_chart = new Highcharts.Chart(
    {
      chart:
        renderTo: "wdl-current-chart"
      title:
        text: "Game statistics for best of current generation"
      tooltip:
        pointFormat: '{point.percentage:.1f}%'
      series:
        [{
          name: "Game statistics"
          type: "pie"
          data: [
            ["Wins", 100/3],
            ["Draws", 100/3]
            ["Losses", 100/3]
          ]
        }]
    },
  )
  worker = undefined
  messageHandler = (e) ->
    if trainerEnabled and e.data.continue
      worker.postMessage({genome: e.data.genome,
      options: training_options})
    else if not e.data.continue
      _genome = new Genome()
      _genome.genes = e.data.genome.genes
      network = _genome.construct()
      numberOfGenerationsSimulated += e.data.delta
      fitness_boxplot_chart.series[0].addPoint([numberOfGenerationsSimulated]
        .concat(e.data.statistics.fitnessValues), true,
        fitness_boxplot_chart.series[0].data.length > 10)
      total = e.data.statistics.best.wins + e.data.statistics.best.draws +
        e.data.statistics.best.losses
      wdl_current_chart.series[0].data[0].update(
        e.data.statistics.best.wins/total * 100)
      wdl_current_chart.series[0].data[1].update(
        e.data.statistics.best.draws/total * 100)
      wdl_current_chart.series[0].data[2].update(
        e.data.statistics.best.losses/total * 100)
      playerO.network = network
      playerO.setupSensors()
    
  container = $("#mynetwork")[0]
  visualizer = new Visualizer(container, {
    physics:
      timestep: 0.1
    height: "60%"
  })


  $("#modal-toggle").click( ->
    $("#mymodal").modal({show: true, backdrop: 'static', keyboard: false})
    if visualizer
      visualizer.draw(network)
  )
  $("#modal-close").click( ->
    $("#mymodal").modal('hide')
    if visualizer
      visualizer.destroy()
  )
  $("#statusmodal-toggle").click( ->
    $("#statusmodal").modal({show: true, backdrop: 'static', keyboard: false})
  )
  $("#statusmodal-close").click( ->
    $("#statusmodal").modal('hide')
  )
  $("#trainer-button").click( ->
    if not trainerEnabled #play → pause
      _genome = new Genome()
      _genome.deconstruct(network)
      worker = undefined
      worker = Work(require('./worker'))
      worker.onmessage = messageHandler
      worker.postMessage({
        genome: _genome
        options: training_options
        numberOfGenerationsSimulated: numberOfGenerationsSimulated
      })
      trainerEnabled = true
      console.log "Start"
      $("#trainer-button span").removeClass("glyphicon-play")
      $("#trainer-button span").addClass("glyphicon-pause")
    else
      worker.terminate()
      trainerEnabled = false
      console.log "End"
      $("#trainer-button span").removeClass("glyphicon-pause")
      $("#trainer-button span").addClass("glyphicon-play")
  )
  game = new TicTacToe()
  currentPlayer = TicTacToe.player.X
  playerO = new NeuralTicTacToePlayer(game, TicTacToe.player.O, network)
  playerO.setupSensors()
  # Set up events for tic tac toe buttons
  updateGrid = (r, c) ->
    $("#i#{r}#{c}").html(
      if currentPlayer == TicTacToe.player.X then "&#x2715;"
      else if currentPlayer == TicTacToe.player.O then "O"
      else "&nbsp;"
    )
  showState = () ->
    result = game.state
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

  $("#restart-btn").click(() ->
    game.newGame()
    currentPlayer = TicTacToe.player.X
    for r in [0..2]
      for c in [0..2]
        $("#i#{r}#{c}").html("&nbsp;")
    $(".tic-tac-toe-end").hide()
  )
  for r in [0..2]
    for c in [0..2]
      do (r, c) ->
        $("#i#{r}#{c}").click(() ->
          if game.getPlayerAt(r, c) == TicTacToe.player.empty
            result = game.move(r, c, currentPlayer)
            updateGrid(r, c)
            result = showState()
            if result == TicTacToe.state.inProgress
              currentPlayer =
                (if currentPlayer == TicTacToe.player.X
                then TicTacToe.player.O
                else TicTacToe.player.X)
              move = playerO.move()
              updateGrid(move.r, move.c)
              showState()
              currentPlayer =
                (if currentPlayer == TicTacToe.player.X
                then TicTacToe.player.O
                else TicTacToe.player.X)
        )
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
      network.link(s, o)
)