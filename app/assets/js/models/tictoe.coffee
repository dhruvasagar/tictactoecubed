class @TicToe
  constructor: (tictactoe, game)->
    @won = ko.observable(false)
    @game = game
    @value = ko.observable('')
    @tictactoe = tictactoe

    @isEmpty = ko.computed =>
      @value().length == 0

    @keypressed = (data, event) =>
      key = String.fromCharCode(event.keyCode)
      regexp = new RegExp('[' + @game.currentPlayer().tic() + ']', 'i')
      if key.match regexp
        @tictactoe.played(this)
        return true
      else
        event.preventDefault()
        return false
