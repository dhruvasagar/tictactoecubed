class @TicTacToe
  constructor: (tictactoecubed, game)->
    @won = ko.observable(false)
    @game = game
    @draw = ko.observable(false)
    @won_x = ko.observable(false)
    @won_o = ko.observable(false)
    @active = ko.observable(false)
    @highlight = ko.observable(false)
    @tictactoecubed = tictactoecubed
    @tictoes = ko.observableArray [
      [new TicToe(this, @game), new TicToe(this, @game), new TicToe(this, @game)],
      [new TicToe(this, @game), new TicToe(this, @game), new TicToe(this, @game)],
      [new TicToe(this, @game), new TicToe(this, @game), new TicToe(this, @game)]
    ]

    @isSolved = ko.computed =>
      @winner_tic() and @winner_tic().length == 1

    @isWon = ko.computed =>
      @won() and tictactoecubed.won()

  indexOf: (tictoe) ->
    for ticrow, i in @tictoes()
      for ttictoe, j in ticrow
        if ttictoe == tictoe
          return [i, j]
    null

  played: (tictoe) ->
    @tictactoecubed.played(this, @indexOf(tictoe))

  set_won: (tic) ->
    @won(true)
    if tic == 'x'
      @won_x(true)
    else
      @won_o(true)

  winner_tic: ->
    for i in [0..2]
      if @tictoes()[i][0].value() != '' and @tictoes()[i][0].value() == @tictoes()[i][1].value() and @tictoes()[i][1].value() == @tictoes()[i][2].value()
        for j in [0..2]
          @tictoes()[i][j].won(true)
        @set_won(@tictoes()[i][0].value())
        return @tictoes()[i][0].value()
      if @tictoes()[0][i].value() != '' and @tictoes()[0][i].value() == @tictoes()[1][i].value() and @tictoes()[1][i].value() == @tictoes()[2][i].value()
        for j in [0..2]
          @tictoes()[j][i].won(true)
        @set_won(@tictoes()[0][i].value())
        return @tictoes()[0][i].value()
    if @tictoes()[1][1].value() != '' and @tictoes()[0][0].value() == @tictoes()[1][1].value() and @tictoes()[1][1].value() == @tictoes()[2][2].value()
      for i in [0..2]
        @tictoes()[i][i].won(true)
      @set_won(@tictoes()[1][1].value())
      return @tictoes()[1][1].value()
    if @tictoes()[1][1].value() != '' and @tictoes()[0][2].value() == @tictoes()[1][1].value() and @tictoes()[1][1].value() == @tictoes()[2][0].value()
      for i in [0..2]
        @tictoes()[i][2-i].won(true)
      @set_won(@tictoes()[1][1].value())
      return @tictoes()[1][1].value()
    null

  isSolvedFor: (tic) ->
    @winner_tic() == tic

  winner: ->
    if tic = @winner_tic()
      @game.getPlayerByTic(tic)

  move: (indexOfTicToe, currentPlayer) ->
    @tictoes()[indexOfTicToe[0]][indexOfTicToe[1]].value(currentPlayer.tic())
