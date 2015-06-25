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
Trainer = require('./Trainer').Trainer
if window?
  window.$ = window.jQuery = jQuery
  Bootstrap = require('bootstrap/dist/js/npm')

jQuery(() ->
  container = $("#mynetwork")[0]
  visualizer = new Visualizer(container, {
    physics:
      timestep: 0.1
    height: "60%"
  })
  network = new NeuralNetwork()
  trainer = undefined
  console.log "initializing"

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
    if not trainer? #play → pause
      trainer = new Trainer(network)
      $("#trainer-button span").removeClass("glyphicon-play")
      $("#trainer-button span").addClass("glyphicon-pause")
    else
      trainer = undefined
      $("#trainer-button span").removeClass("glyphicon-pause")
      $("#trainer-button span").addClass("glyphicon-play")
  )
  game = new TicTacToe()
  currentPlayer = TicTacToe.player.X
  playerO = new RandomTicTacToePlayer(game, TicTacToe.player.O)
  # Set up events for tic tac toe buttons
  updateGrid = (r, c) =>
    $("#i#{r}#{c}").html(
      if currentPlayer == TicTacToe.player.X then "&#x2715;"
      else if currentPlayer == TicTacToe.player.O then "O"
      else "&nbsp;"
    )
  showState = () =>
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

  $("#restart-btn").click(() =>
    game.newGame()
    currentPlayer = TicTacToe.player.X
    for r in [0..2]
      for c in [0..2]
        $("#i#{r}#{c}").html("&nbsp;")
    $(".tic-tac-toe-end").hide()
  )
  for r in [0..2]
    for c in [0..2]
      do (r, c) =>
        $("#i#{r}#{c}").click(() =>
          if game.getPlayerAt(r, c) == TicTacToe.player.empty
            result = game.move(r, c, currentPlayer)
            updateGrid(r, c)
            result = showState()
            if result == TicTacToe.state.inProgress
              currentPlayer =
                (if currentPlayer == TicTacToe.player.X then TicTacToe.player.O
                else TicTacToe.player.X)
              move = playerO.move()
              updateGrid(move.r, move.c)
              showState()
              currentPlayer =
                (if currentPlayer == TicTacToe.player.X then TicTacToe.player.O
                else TicTacToe.player.X)
        )
  # Actual simulation code
  interval = (time, fn) -> setTimeout( ->
    fn()
    interval(time, fn)
  , time)
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
  interval 2000, ->
    if trainer?
      trainer.train()
      network = trainer.network
)