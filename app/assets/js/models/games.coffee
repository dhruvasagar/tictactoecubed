class Game
  constructor: (game, socket) ->
    @id = ko.observable(game._id)
    @state = ko.observable(game.state)
    @winner = ko.observable(game.winner)
    @moves = ko.observableArray(game.moves)
    @players = ko.observableArray([])
    @updated_at = ko.observable(game.updated_at)

    @when = ko.computed =>
      moment(@updated_at()).fromNow()

    @url = ko.observable("/games/#{@id()}")
    @join_url = "#{@url()}/join"

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
    location.href = @url()

  shareClick: (data, event) ->
    target = $(event.target)
    share_via = target.attr('data-share-via')
    url = location.protocol + '//' + location.host + @url()

    share_dialog = []
    if share_via == 'facebook'
      share_dialog.push "https://www.facebook.com/sharer/sharer.php?u=#{encodeURIComponent(url)}"
      share_dialog.push 'facebook-share-dialog'
    else if share_via == 'twitter'
      share_dialog.push "https://twitter.com/share?url=#{url}&hashtags=tictactoecubed&text=Join me in a game of tic tac toe cubed"
      share_dialog.push 'twitter-share-dialog'
    else if share_via == 'google'
      share_dialog.push "https://plus.google.com/share?url=#{url}"
      share_dialog.push 'google-share-dialog'
    share_dialog.push 'width=626,height=436'
    window.open.apply window, share_dialog

    event.stopPropagation()
    return false

  selectInput: (data, event) ->
    $(event.target).select()
    event.stopPropagation()
    return false

  joinGame: (data, event) =>
    if $(event.target).hasClass('disabled')
      return
    else
      event.stopPropagation()
      socket.emit 'game.enter',
        avatar: user.avatar
        game_id: @id()
        user_id: window.currentUserId
        user_name: user.name
      socket.emit('game.join')
      location.href = data.join_url

class @Games
  constructor: (games, socket) ->
    _games = $.map games, (game) ->
      new Game(game, socket)
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
