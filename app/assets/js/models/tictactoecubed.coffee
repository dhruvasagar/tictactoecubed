class @TicTacToeCubed
  constructor: (game)->
    @won = ko.observable(false)
    @game = game
    @won_x = ko.observable(false)
    @won_o = ko.observable(false)
    @active = ko.observable(false)
    @tictactoes = ko.observableArray [
      [new TicTacToe(this, @game), new TicTacToe(this, @game), new TicTacToe(this, @game)],
      [new TicTacToe(this, @game), new TicTacToe(this, @game), new TicTacToe(this, @game)],
      [new TicTacToe(this, @game), new TicTacToe(this, @game), new TicTacToe(this, @game)]
    ]

    @draw = ko.computed =>
      return false if @won()
      for tictacrow, i in @tictactoes()
        for tictactoe, j in tictacrow
          return false unless tictactoe.won() || tictactoe.draw()
      return true

    @isSolved = ko.computed =>
      @winner_tic() and @winner_tic().length == 1

  indexOf: (tictactoe) ->
    for tictacrow, i in @tictactoes()
      for ttictactoe, j in tictacrow
        if ttictactoe == tictactoe
          return [i, j]
    null

  played: (tictactoe, indexOfTicToe) ->
    @game.step(@indexOf(tictactoe), indexOfTicToe)

  set_won: (tic) ->
    @won(true)
    if tic == 'x'
      @won_x(true)
    else
      @won_o(true)

  activate: (flag = true, hlflag = true) ->
    for tictactoerow in @tictactoes()
      for tictactoe in tictactoerow
        unless tictactoe.won() || tictactoe.draw()
          tictactoe.active(flag)
          tictactoe.highlight(hlflag)

  winner_tic: ->
    for i in [0..2]
      if @tictactoes()[i][0].winner_tic() != null and @tictactoes()[i][0].winner_tic() == @tictactoes()[i][1].winner_tic() and @tictactoes()[i][1].winner_tic() == @tictactoes()[i][2].winner_tic()
        for j in [0..2]
          @tictactoes()[i][j].won(true)
        @set_won(@tictactoes()[i][0].winner_tic())
        return @tictactoes()[i][0].winner_tic()
      if @tictactoes()[0][i].winner_tic() != null and @tictactoes()[0][i].winner_tic() == @tictactoes()[1][i].winner_tic() and @tictactoes()[1][i].winner_tic() == @tictactoes()[2][i].winner_tic()
        for j in [0..2]
          @tictactoes()[j][i].won(true)
        @set_won(@tictactoes()[0][i].winner_tic())
        return @tictactoes()[0][i].winner_tic()
    if @tictactoes()[1][1].winner_tic() != null and @tictactoes()[0][0].winner_tic() == @tictactoes()[1][1].winner_tic() and @tictactoes()[1][1].winner_tic() == @tictactoes()[2][2].winner_tic()
      for i in [0..2]
        @tictactoes()[i][i].won(true)
      @set_won(@tictactoes()[1][1].winner_tic())
      return @tictactoes()[1][1].winner_tic()
    if @tictactoes()[1][1].winner_tic() != null and @tictactoes()[0][2].winner_tic() == @tictactoes()[1][1].winner_tic() and @tictactoes()[1][1].winner_tic() == @tictactoes()[2][0].winner_tic()
      for i in [0..2]
        @tictactoes()[i][2-i].won(true)
      @set_won(@tictactoes()[1][1].winner_tic())
      return @tictactoes()[1][1].winner_tic()
    null

  isSolvedFor: (tic) ->
    @winner_tic() == tic

  move: (indexOfTicTacToe, indexOfTicToe, currentPlayer) ->
    @tictactoes()[indexOfTicTacToe[0]][indexOfTicTacToe[1]].move(indexOfTicToe, currentPlayer)
