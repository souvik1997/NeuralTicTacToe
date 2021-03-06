extend = require('node.extend')
class TicTacToe
  constructor: (rows = 3, columns = 3, k = 3) ->
    @dimensions = {r: rows, c: columns, k: k}
    @newGame()
    @currentPlayer = TicTacToe.player.X

  move: (r, c, player) ->
    if player != @currentPlayer
      return @state
    if @isAValidPosition(r, c) and @board[r][c] == TicTacToe.player.empty
      @board[r][c] = player
      value = @_checkWin(r, c)
      if value != TicTacToe.player.empty
        @state = value
      else if @_checkDraw()
        @state = TicTacToe.state.draw
      @currentPlayer =
        (if @currentPlayer == TicTacToe.player.X
        then TicTacToe.player.O
        else TicTacToe.player.X)
    return @state

  isAValidPosition: (r, c) ->
    return r < @dimensions.r and c < @dimensions.c and r >= 0 and c >= 0

  getPlayerAt: (r, c) ->
    if not @isAValidPosition(r, c)
      return TicTacToe.player.null
    return @board[r][c]

  newGame: (resetCurrentPlayer = false) ->
    @state = TicTacToe.state.inProgress
    @board = []
    for r in [1..@dimensions.r]
      row = []
      for c in [1..@dimensions.c]
        row.push(TicTacToe.player.empty)
      @board.push(row)
    if resetCurrentPlayer
      @currentPlayer = TicTacToe.player.X

  _checkDraw: () ->
    if @state == TicTacToe.state.xWin or @state == TicTacToe.state.yWin
      return false
    emptySpaces = 0
    for r in [0..@dimensions.r-1]
      emptySpaces += @board[r].filter((x) -> x == TicTacToe.player.empty).length
    return emptySpaces == 0

  _checkWin: (r, c) ->
    checkColumn = (r, c) =>
      xsum = 0
      osum = 0
      r = 0
      while @isAValidPosition(r, c) and Math.abs(xsum) != @dimensions.k and
      Math.abs(osum) != @dimensions.k
        if @getPlayerAt(r, c) == TicTacToe.player.X
          xsum++
          osum = 0
        else if @getPlayerAt(r, c) == TicTacToe.player.O
          osum--
          xsum = 0
        else
          xsum = 0
          osum = 0
        r++
      if osum == -@dimensions.k
        return TicTacToe.player.O
      else if xsum == @dimensions.k
        return TicTacToe.player.X
      else
        return TicTacToe.player.empty
    checkRow = (r, c) =>
      xsum = 0
      osum = 0
      c = 0
      while @isAValidPosition(r, c) and Math.abs(xsum) != @dimensions.k and
      Math.abs(osum) != @dimensions.k
        if @getPlayerAt(r, c) == TicTacToe.player.X
          xsum++
          osum = 0
        else if @getPlayerAt(r, c) == TicTacToe.player.O
          osum--
          xsum = 0
        else
          xsum = 0
          osum = 0
        c++
      if osum == -@dimensions.k
        return TicTacToe.player.O
      else if xsum == @dimensions.k
        return TicTacToe.player.X
      else
        return TicTacToe.player.empty
    checkForwardDiagonal = (r, c) => # /
      xsum = 0
      osum = 0
      while @isAValidPosition(r, c)
        r++
        c--
      r--
      c++
      while @isAValidPosition(r, c) and
      Math.abs(xsum) != @dimensions.k and
      Math.abs(osum) != @dimensions.k
        if @getPlayerAt(r, c) == TicTacToe.player.X
          xsum++
          osum = 0
        else if @getPlayerAt(r, c) == TicTacToe.player.O
          osum--
          xsum = 0
        else
          xsum = 0
          osum = 0
        r--
        c++
      if osum == -@dimensions.k
        return TicTacToe.player.O
      else if xsum == @dimensions.k
        return TicTacToe.player.X
      else
        return TicTacToe.player.empty
    checkBackwardsDiagonal = (r, c) => # \
      xsum = 0
      osum = 0
      while @isAValidPosition(r, c)
        r--
        c--
      r++
      c++
      while @isAValidPosition(r, c) and
      Math.abs(xsum) != @dimensions.k and
      Math.abs(osum) != @dimensions.k
        if @getPlayerAt(r, c) == TicTacToe.player.X
          xsum++
          osum = 0
        else if @getPlayerAt(r, c) == TicTacToe.player.O
          osum--
          xsum = 0
        else
          xsum = 0
          osum = 0
        r++
        c++
      if osum == -@dimensions.k
        return TicTacToe.player.O
      else if xsum == @dimensions.k
        return TicTacToe.player.X
      else
        return TicTacToe.player.empty
    status = [checkRow(r, c), checkColumn(r, c), checkBackwardsDiagonal(r, c)
    checkForwardDiagonal(r, c)]
    .filter((x) => x == @getPlayerAt(r,c))[0]
    return status ? TicTacToe.player.empty
  clone: () ->
    g = new TicTacToe(@dimensions.r, @dimensions.c, @dimensions.k)
    for r in [0..@dimensions.r-1]
      for c in [0..@dimensions.c-1]
        g.board[r][c] = @board[r][c]
    g.state = @state
    g.currentPlayer = @currentPlayer
    return g
TicTacToe.player = {
  X: 1
  O: 2
  empty: 0
  null: -1
}
TicTacToe.state = {
  xWin: TicTacToe.player.X
  oWin: TicTacToe.player.O
  draw: 0
  inProgress: -1
}
root = module.exports ? this
root.TicTacToe = TicTacToe