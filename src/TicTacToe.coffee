class TicTacToe
  constructor: () ->
    @dimensions = {r: 3, c: 3}
    @state = TicTacToe.state.inProgress
    @board = []
    for r in [1..@dimensions.r]
      row = []
      for c in [1..@dimensions.c]
        row.push(TicTacToe.player.empty)
      @board.push(row)

  move: (r, c, player) ->
    if @isAValidPosition(r, c)
      @board[r][c] = player
      value = @_checkWin(r, c)
      if value != TicTacToe.player.empty
        @state = value
      else if @_checkDraw()
        @state = TicTacToe.state.draw
    return @state

  isAValidPosition: (r, c) ->
    return r < @dimensions.r and c < @dimensions.c and r >= 0 and c >= 0

  getPlayerAt: (r, c) ->
    if not @isAValidPosition(r, c)
      return TicTacToe.player.null
    return @board[r][c]

  _checkDraw: () ->
    if @state == TicTacToe.state.xWin or @state == TicTacToe.state.yWin
      return false
    emptySpaces = 0
    for r in [0..@dimensions.r-1]
      emptySpaces += @board[r].filter((x) -> x == TicTacToe.player.empty).length
    return emptySpaces == 0

  _checkWin: (r, c) ->
    checkColumn = (r, c) =>
      sum = 0
      r = 0
      while @isAValidPosition(r, c) and Math.abs(sum) != @dimensions.r
        if @getPlayerAt(r, c) == TicTacToe.player.X
          sum++
        else if @getPlayerAt(r, c) == TicTacToe.player.O
          sum--
        r++
      if sum == -@dimensions.r
        return TicTacToe.player.O
      else if sum == @dimensions.r
        return TicTacToe.player.X
      else
        return TicTacToe.player.empty
    checkRow = (r, c) =>
      sum = 0
      c = 0
      while @isAValidPosition(r, c) and Math.abs(sum) != @dimensions.c
        if @getPlayerAt(r, c) == TicTacToe.player.X
          sum++
        else if @getPlayerAt(r, c) == TicTacToe.player.O
          sum--
        c++
      if sum == -@dimensions.c
        return TicTacToe.player.O
      else if sum == @dimensions.c
        return TicTacToe.player.X
      else
        return TicTacToe.player.empty
    checkForwardDiagonal = (r, c) => # /
      sum = 0
      while @isAValidPosition(r, c)
        r++
        c--
      r--
      c++
      while @isAValidPosition(r, c) and
      Math.abs(sum) != Math.min(@dimensions.r, @dimensions.c)
        if @getPlayerAt(r, c) == TicTacToe.player.X
          sum++
        else if @getPlayerAt(r, c) == TicTacToe.player.O
          sum--
        r--
        c++
      if sum == -Math.min(@dimensions.r, @dimensions.c)
        return TicTacToe.player.O
      else if sum == Math.min(@dimensions.r, @dimensions.c)
        return TicTacToe.player.X
      else
        return TicTacToe.player.empty
    checkBackwardsDiagonal = (r, c) => # \
      sum = 0
      while @isAValidPosition(r, c)
        r--
        c--
      r++
      c++
      while @isAValidPosition(r, c) and
      Math.abs(sum) != Math.min(@dimensions.r, @dimensions.c)
        if @getPlayerAt(r, c) == TicTacToe.player.X
          sum++
        else if @getPlayerAt(r, c) == TicTacToe.player.O
          sum--
        r++
        c++
      if sum == -Math.min(@dimensions.r, @dimensions.c)
        return TicTacToe.player.O
      else if sum == Math.min(@dimensions.r, @dimensions.c)
        return TicTacToe.player.X
      else
        return TicTacToe.player.empty
    status = [checkRow(r, c), checkColumn(r, c), checkBackwardsDiagonal(r, c)
    checkForwardDiagonal(r, c)]
    .filter((x) => x == @getPlayerAt(r,c))[0]
    return status ? TicTacToe.player.empty
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
  inProgress: 0
}
root = module.exports ? this
root.TicTacToe = TicTacToe