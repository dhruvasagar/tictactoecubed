class Game
  constructor: (game) ->
    @_id = ko.observable(game._id)
    @state = ko.observable(game.state)
    @winner = ko.observable(game.winner)
    @players = ko.observable(game.players)
    @player1 = ko.computed =>
      return @players()[0].name if @players()[0]
      return ''
    @player2 = ko.computed =>
      return @players()[1].name if @players()[1]
      return ''
    @actions = ko.computed =>
      actions = ''
      actions += "<a href='/games/" + game._id + "'><i class='icon-fixed-width icon-play'></i></a>"
      actions += "<a href='/games/" + game._id + "/join'><i class='icon-fixed-width icon-signin'></i></a>" +
        "<a><i class='icon-fixed-width icon-remove'></i></a>"

class @Games
  constructor: (games) ->
    _games = $.map games, (game) ->
      new Game(game)
    @games = ko.observableArray(_games || [])
