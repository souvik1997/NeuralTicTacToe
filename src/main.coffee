jQuery = require('jquery')
Neuron = require('./Neuron').Neuron
SensoryNeuron = require('./Neuron').SensoryNeuron
OutputNeuron = require('./Neuron').OutputNeuron
Visualizer = require('./Visualizer').Visualizer
NeuralNetwork = require('./NeuralNetwork').NeuralNetwork
Genome = require('./Genome').Genome
TicTacToe = require('./TicTacToe').TicTacToe
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
  sensory_neurons = []
  output_neurons = []
  for x in [0..2]
    for y in [0..2]
      sensory_neurons.push new SensoryNeuron(text: "("+x+","+y+")")
      output_neurons.push new OutputNeuron(text: "("+x+","+y+")")
  for s in sensory_neurons
    for o in output_neurons
      @network.link(s, o)
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
  # Set up events for tic tac toe buttons
  @currentPlayer = TicTacToe.player.X
  @TicTacToe = new TicTacToe()
  $("#restart-btn").click(() =>
    @TicTacToe.newGame()
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
            $("#i#{r}#{c}").html(
              if @currentPlayer == TicTacToe.player.X then "&#x2715;"
              else if @currentPlayer == TicTacToe.player.O then "O"
              else "&nbsp;"
            )
            @currentPlayer =
              (if @currentPlayer == TicTacToe.player.X then TicTacToe.player.O
              else TicTacToe.player.X)
            if result == TicTacToe.state.draw
              $(".tic-tac-toe-notification").html("Draw!")
              $(".tic-tac-toe-end").show()
            else if result == TicTacToe.state.xWin
              $(".tic-tac-toe-notification").html("X wins!")
              $(".tic-tac-toe-end").show()
            else if result == TicTacToe.state.oWin
              $(".tic-tac-toe-notification").html("O wins!")
              $(".tic-tac-toe-end").show()
        )
)