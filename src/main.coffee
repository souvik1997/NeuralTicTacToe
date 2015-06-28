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
IdealTicTacToePlayer = require('./IdealTicTacToePlayer').IdealTicTacToePlayer
dat = require('dat-gui')
if not window? or not window.Worker? or JasmineEnabled
  return
window.$ = window.jQuery = jQuery = require('jquery')
require('bootstrap/dist/js/npm')
require('highcharts-release/highcharts.src.js')
require('highcharts-release/highcharts-more.src.js')


game = new TicTacToe()
currentPlayer = TicTacToe.player.empty
opponents = []
opponent = undefined
prevdimensions = {}
trainerEnabled = false
numberOfGenerationsSimulated = 0
wdl_neat_current_chart = undefined
fitness_boxplot_chart = undefined
options =
{
  game:
    opponent: "ideal"
    dimensions:
      rows: 3
      columns: 3
      k: 3
  training:
    fitInheritanceProbability: 1
    numToCreate: 20
    gamesToPlay: 20
    target: 4000
    learningrate: 1
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
        probability: 0.001
      hiddenlayer_deletion:
        probability: 0.001
}
neatworker = undefined
backpropworker = undefined
messageHandler = (e) ->
  if e.data.update == "neat"
    network = NeuralNetwork.fromArray(e.data.neat.network)
    numberOfGenerationsSimulated += e.data.neat.delta
    fitness_boxplot_chart.series[0].addPoint([numberOfGenerationsSimulated]
      .concat(e.data.neat.statistics.fitnessValues), true,
      fitness_boxplot_chart.series[0].data.length > 10)
    total = e.data.neat.statistics.best.wins +
      e.data.neat.statistics.best.draws +
      e.data.neat.statistics.best.losses
    wdl_neat_current_chart.series[0].data[0].update(
      e.data.neat.statistics.best.wins/total * 100)
    wdl_neat_current_chart.series[0].data[1].update(
      e.data.neat.statistics.best.draws/total * 100)
    wdl_neat_current_chart.series[0].data[2].update(
      e.data.neat.statistics.best.losses/total * 100)
    opponents[2].network = network
    if opponents[2].setupSensors?
      opponents[2].setupSensors()
  if e.data.update == "backprop"
    network = NeuralNetwork.fromArray(e.data.backprop.network)
    opponents[3].network = network
    if opponents[3].setupSensors?
      opponents[3].setupSensors()
createGameBoard = () ->
  game = new TicTacToe(options.game.dimensions.rows,
    options.game.dimensions.columns, options.game.dimensions.k)
  updateGrid = (r, c, player) ->
    $("#i#{r}#{c}").html(
      if player == TicTacToe.player.X then "&#x2715;"
      else if player == TicTacToe.player.O then "O"
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
  $("#restart-btn").off('click.main')
  $("#restart-btn").on('click.main', ->
    game.newGame()
    for r in [0..options.game.dimensions.rows-1]
      for c in [0..options.game.dimensions.columns-1]
        $("#i#{r}#{c}").html("&nbsp;")
    $(".tic-tac-toe-end").hide()
    if game.currentPlayer == TicTacToe.player.O
      move = opponent.move()
      updateGrid(move.r, move.c, TicTacToe.player.O)
      showState()
  )
  $("#game-board").empty()
  board = $("#game-board").detach()
  for r in [0..options.game.dimensions.rows-1]
    board.append($("<tr id='game-row-#{r}'></tr>"))
    for c in [0..options.game.dimensions.columns-1]
      do (r, c) ->
        unit = $("<td><button class='btn tic-tac-toe-btn'
          id='i#{r}#{c}'>&nbsp;</button></td>")
        
        unit.off('click.main')
        unit.on('click.main', ->
          if game.getPlayerAt(r, c) == TicTacToe.player.empty
            x = game.currentPlayer
            result = game.move(r, c, game.currentPlayer)
            updateGrid(r, c, x)
            result = showState()
            if result == TicTacToe.state.inProgress
              x = game.currentPlayer
              move = opponent.move()
              updateGrid(move.r, move.c, x)
              showState()
        )
        size = 75/Math.max(options.game.dimensions.columns,
          options.game.dimensions.rows)
        unit.find(".btn").css("width","#{size}vh")
        unit.find(".btn").css("height","#{size}vh")
        board.find("#game-row-#{r}").append(unit)
  $(".tic-tac-toe-container").append(board)
  for r in [0..options.game.dimensions.rows-1]
    for c in [0..options.game.dimensions.columns-1]
      $("#i#{r}#{c}").css("font-size", ""+($("#i#{r}#{c}").width() * 0.9))
visualizer = undefined
setupVisualizer = () ->
  container = $("#mynetwork")[0]
  visualizer = new Visualizer(container, {
    physics:
      timestep: 0.1
    height: "60%"
  })


resetStats = () ->
  if neatworker?
    neatworker.terminate()
  if backpropworker?
    backpropworker.terminate()
  $("#trainer-button span").removeClass("glyphicon-pause")
  $("#trainer-button span").addClass("glyphicon-play")
  for series in fitness_boxplot_chart.series
    series.setData([])
  numberOfGenerationsSimulated = 0
  trainerEnabled = false
initialize = () ->
  resetStats()
  createGameBoard()
  opponents[0] = new RandomTicTacToePlayer(game, TicTacToe.player.O)
  opponents[1] = new IdealTicTacToePlayer(game, TicTacToe.player.O)
  opponents[2] = new NeuralTicTacToePlayer(game, TicTacToe.player.O, undefined)
  opponents[3] = new NeuralTicTacToePlayer(game, TicTacToe.player.O, undefined)
  network = new NeuralNetwork()
  sensory_neurons = []
  output_neurons = []
  for r in [0..options.game.dimensions.rows-1]
    for c in [0..options.game.dimensions.columns-1]
      sensory_neurons.push new SensoryNeuron(
        text: "("+r+","+c+")",
        id:10+r+c/10)
      output_neurons.push new OutputNeuron(
        text: "("+r+","+c+")",
        id:20+r+c/10)
  for s in sensory_neurons
    for o in output_neurons
      network.link(s, o)
  opponents[2].network = network
  opponents[3].network = network
  opponents[2].setupSensors()
  opponents[3].setupSensors()
  prevdimensions.rows = options.game.dimensions.rows
  prevdimensions.columns = options.game.dimensions.columns
  prevdimensions.k = options.game.dimensions.k
  if options.game.opponent == "random"
    opponent = opponents[0]
  if options.game.opponent == "ideal"
    opponent = opponents[1]
  if options.game.opponent == "neural (NEAT)"
    opponent = opponents[2]
  if options.game.opponent == "neural (backprop)"
    opponent = opponents[3]

jQuery(() ->
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
  wdl_neat_current_chart = new Highcharts.Chart(
    {
      chart:
        renderTo: "wdl-neat-current-chart"
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
  $("#modal-toggle").off('click.main')
  $("#modal-toggle").on('click.main', ->
    $("#mymodal").modal({show: true, backdrop: 'static', keyboard: false})
    if visualizer
      visualizer.draw(opponents[2].network)
  )
  $("#modal-close").off('click.main')
  $("#modal-close").on('click.main', ->
    $("#mymodal").modal('hide')
    if visualizer
      visualizer.destroy()
  )
  $("#statusmodal-toggle").off('click.main')
  $("#statusmodal-toggle").on('click.main', ->
    $("#statusmodal").modal({show: true, backdrop: 'static', keyboard: false})
  )
  $("#statusmodal-close").off('click.main')
  $("#statusmodal-close").on('click.main', ->
    $("#statusmodal").modal('hide')
  )
  $("#trainer-button").off('click.main')
  $("#trainer-button").on('click.main', ->
    if not trainerEnabled #play → pause
      neatworker = undefined
      neatworker = Work(require('./neatworker'))
      neatworker.onmessage = messageHandler
      neatworker.postMessage(JSON.stringify {
        neat:
          network: opponents[2].network
        options: options
        numberOfGenerationsSimulated: numberOfGenerationsSimulated
      })
      backpropworker = undefined
      backpropworker = Work(require('./backpropworker'))
      backpropworker.onmessage = messageHandler
      backpropworker.postMessage(JSON.stringify {
        backprop:
          network: opponents[3].network
        options: options
        numberOfGenerationsSimulated: numberOfGenerationsSimulated
      })
      trainerEnabled = true
      console.log "Start"
      $("#trainer-button span").removeClass("glyphicon-play")
      $("#trainer-button span").addClass("glyphicon-pause")
    else
      neatworker.terminate()
      backpropworker.terminate()
      trainerEnabled = false
      console.log "End"
      $("#trainer-button span").removeClass("glyphicon-pause")
      $("#trainer-button span").addClass("glyphicon-play")
  )
  gui = new dat.GUI({autoPlace: false})
  game = gui.addFolder('game')
  game.add(options.game, 'opponent', ['neural (NEAT)',
    'neural (backprop)', 'random', 'ideal']).onFinishChange(
    (value) ->
      if options.game.opponent == "random"
        opponent = opponents[0]
      if options.game.opponent == "ideal"
        opponent = opponents[1]
      if options.game.opponent == "neural (NEAT)"
        opponent = opponents[2]
      if options.game.opponent == "neural (backprop)"
        opponent = opponents[3]
    )
  game.add(options.game.dimensions, 'rows').min(0).max(19).step(1)
    .onFinishChange((value) -> initialize())
  game.add(options.game.dimensions, 'columns').min(0).max(19).step(1)
    .onFinishChange((value) -> initialize())
  game.add(options.game.dimensions, 'k').min(0).max(19).step(1)
    .onFinishChange((value) -> initialize())
  training = gui.addFolder('training')
  training.add(options.training, 'fitInheritanceProbability', 0, 1)
    .onFinishChange((value) -> resetStats())
  training.add(options.training, 'numToCreate').min(0).max(100).step(1)
    .onFinishChange((value) -> resetStats())
  training.add(options.training, 'gamesToPlay').min(0).max(100).step(1)
    .onFinishChange((value) -> resetStats())
  training.add(options.training, 'target').min(0).max(4000)
    .onFinishChange((value) -> resetStats())
  training.add(options.training, 'learningrate').min(0).max(3)
    .onFinishChange((value) -> resetStats())
  training.add(options.training, 'randomPlayerDifficulty').min(-100).max(100)
    .onFinishChange((value) -> resetStats())
  weight = training.addFolder('weight')
  weight.add(options.training.weight, 'win', -30, 30)
    .onFinishChange((value) -> resetStats())
  weight.add(options.training.weight, 'draw', -30, 30)
    .onFinishChange((value) -> resetStats())
  weight.add(options.training.weight, 'loss', -30, 30)
    .onFinishChange((value) -> resetStats())
  mutate = training.addFolder('mutate')
  weightchange = mutate.addFolder('weightchange')
  weightchange.add(options.training.mutate.weightchange, 'probability', 0, 1)
    .onFinishChange((value) -> resetStats())
  weightchange.add(options.training.mutate.weightchange, 'scale', 0, 100)
    .onFinishChange((value) -> resetStats())
  reroute = mutate.addFolder('reroute')
  reroute.add(options.training.mutate.reroute, 'probability',
    0, 1).onFinishChange((value) -> resetStats())
  route_insertion = mutate.addFolder('route_insertion')
  route_insertion.add(options.training.mutate.route_insertion, 'probability',
    0, 1).onFinishChange((value) -> resetStats())
  route_deletion = mutate.addFolder('route_deletion')
  route_deletion.add(options.training.mutate.route_deletion,
    'probability', 0, 1).onFinishChange((value) -> resetStats())
  hiddenlayer_deletion = mutate.addFolder('hiddenlayer_deletion')
  hiddenlayer_deletion.add(options.training.mutate.hiddenlayer_deletion,
    'probability', 0, 1).onFinishChange((value) -> resetStats())
  $(gui.domElement).css("position","absolute").css("z-index","10")
    .prependTo("#main")

  
  initialize()
  setupVisualizer()
)