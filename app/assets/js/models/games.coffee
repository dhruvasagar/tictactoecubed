class Game
  constructor: (game) ->
    @id = ko.observable(game._id)
    @state = ko.observable(game.state)
    @winner = ko.observable(game.winner)
    @players = ko.observableArray([])

    if game.players
      for player in game.players
        @players.push (new Player(player))

    @player1 = ko.computed =>
      return @players()[0] if @players()[0]
      return null
    @player2 = ko.computed =>
      return @players()[1] if @players()[1]
      return null

    @actions = ko.computed =>
      actions = ''
      actions += "<a href='/games/" + @id()+ "'><i class='icon-fixed-width icon-play'></i></a>"
      actions += "<a href='/games/" + @id()+ "/join'><i class='icon-fixed-width icon-signin'></i></a>" +
        "<a><i class='icon-fixed-width icon-remove'></i></a>"

    @showGame = (data, event)=>
      location.href = '/games/' + @id()

    @joinGame = (data, event) =>
      if $(event.target).hasClass('disabled')
        return true
      else
        event.stopPropagation()
        socket.emit('game.join')
        location.href = '/games/' + @id() + '/join'

    @canJoin = ko.computed =>
      !@players()[1] && @players()[0] && !@players()[0].isCurrentPlayer()

class @Games
  constructor: (games, socket) ->
    _games = $.map games, (game) ->
      new Game(game)
    @games = ko.observableArray(_games || [])
