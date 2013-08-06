class Game
  constructor: (game) ->
    @id = ko.observable(game._id)
    @state = ko.observable(game.state)
    @winner = ko.observable(game.winner)
    @moves = ko.observableArray(game.moves)
    @players = ko.observableArray([])

    @url = "/games/#{@id()}"
    @join_url = "#{@url}/join"

    if game.players
      for player in game.players
        @players.push(new Player(player))

    @player1 = ko.computed =>
      return @players()[0] if @players()[0]
      return null

    @player2 = ko.computed =>
      return @players()[1] if @players()[1]
      return null

    @canJoin = ko.computed =>
      !@players()[1] && @players()[0] && !@players()[0].isCurrentPlayer()

  showGame: (data, event) ->
    location.href = @url

  shareClick: (data, event) ->
    target = $(event.target)
    share_via = target.attr('data-share-via')
    url = location.protocol + '//' + location.host + @url
    if share_via == 'facebook'
      window.open('https://www.facebook.com/sharer/sharer.php?u='+encodeURIComponent(url), 'facebook-share-dialog', 'width=626,height=436')
    else if share_via == 'twitter'
      window.open("https://twitter.com/share?url=#{url}&text=Join me in a game of tic tac toe cubed&hashtags=#tictactoecubed", 'twitter-share-dialog', 'width=626,height=436')
    else if share_via == 'google'
      window.open("https://plus.google.com/share?url=#{url}", 'google-share-dialog', 'width=626,height=436')
    event.stopPropagation()
    return false

  joinGame: (data, event) ->
    if $(event.target).hasClass('disabled')
      return
    else
      event.stopPropagation()
      socket.emit('game.join')
      location.href = data.join_url

class @Games
  constructor: (games, socket) ->
    _games = $.map games, (game) ->
      new Game(game)
    @games = ko.observableArray(_games)
    @activeTab = ko.observable('started')
    @filteredGames = ko.observableArray(ko.utils.arrayFilter(_games, (game) ->
      game.state() == 'started'
    ))

  tabClick: (data, event) ->
    href = $(event.target).attr('href').substring(1)
    @activeTab(href)
    @filteredGames ko.utils.arrayFilter @games(), (game) ->
      game.state() == href
