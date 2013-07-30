class @TicTacToeCubed
  constructor: (game)->
    @won = ko.observable(false)
    @game = game
    @active = ko.observable(false)
    @tictactoes = ko.observableArray [
      [new TicTacToe(this, @game), new TicTacToe(this, @game), new TicTacToe(this, @game)],
      [new TicTacToe(this, @game), new TicTacToe(this, @game), new TicTacToe(this, @game)],
      [new TicTacToe(this, @game), new TicTacToe(this, @game), new TicTacToe(this, @game)]
    ]

    @isSolved = ko.computed =>
      @winner_tic() and @winner_tic().length == 1

    @winner = ko.computed =>
      tic = @winner_tic()
      if tic
        @game.getPlayerByTic(tic)

  indexOf: (tictactoe) ->
    for tictacrow, i in @tictactoes()
      for ttictactoe, j in tictacrow
        if ttictactoe == tictactoe
          return [i, j]
    null

  played: (tictactoe, indexOfTicToe) ->
    @game.step(@indexOf(tictactoe), indexOfTicToe)

  activate: (flag = true) ->
    for tictactoerow in @tictactoes()
      for tictactoe in tictactoerow
        tictactoe.active(flag)
        tictactoe.highlight(flag)

  winner_tic: ->
    for i in [0..2]
      if @tictactoes()[i][0].winner_tic() != null and @tictactoes()[i][0].winner_tic() == @tictactoes()[i][1].winner_tic() and @tictactoes()[i][1].winner_tic() == @tictactoes()[i][2].winner_tic()
        for j in [0..2]
          @tictactoes()[i][j].won(true)
        return @tictactoes()[i][0].winner_tic()
      if @tictactoes()[0][i].winner_tic() != null and @tictactoes()[0][i].winner_tic() == @tictactoes()[1][i].winner_tic() and @tictactoes()[1][i].winner_tic() == @tictactoes()[2][i].winner_tic()
        for j in [0..2]
          @tictactoes()[j][i].won(true)
        return @tictactoes()[0][i].winner_tic()
    if @tictactoes()[1][1].winner_tic() != null and @tictactoes()[0][0].winner_tic() == @tictactoes()[1][1].winner_tic() and @tictactoes()[1][1].winner_tic() == @tictactoes()[2][2].winner_tic()
      for i in [0..2]
        @tictactoes()[i][i].won(true)
      return @tictactoes()[1][1].winner_tic()
    if @tictactoes()[1][1].winner_tic() != null and @tictactoes()[0][2].winner_tic() == @tictactoes()[1][1].winner_tic() and @tictactoes()[1][1].winner_tic() == @tictactoes()[2][0].winner_tic()
      for i in [0..2]
        @tictactoes()[i][2-i].won(true)
      return @tictactoes()[1][1].winner_tic()
    null

  isSolvedFor: (tic) ->
    @winner_tic() == tic

  move: (indexOfTicTacToe, indexOfTicToe, currentPlayer) ->
    @tictactoes()[indexOfTicTacToe[0]][indexOfTicTacToe[1]].move(indexOfTicToe, currentPlayer)
