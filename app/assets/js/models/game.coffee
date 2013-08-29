class @Game
  constructor: (game, socket) ->
    @id = ko.observable(game._id)
    @moves = game.moves
    @state = ko.observable(game.state || 'new')
    @players = ko.observableArray([])
    @messages = ko.observableArray([])
    @currentPlayer = ko.observable()
    @tictactoecubed = ko.observable(new TicTacToeCubed(this))

    @url = ko.observable("/games/#{@id()}")
    @join_url = "#{@url()}/join"

    if game.players && game.players.length
      for player in game.players
        @addPlayer(player)

    @player1 = ko.computed =>
      return @players()[0] if @players()[0]
      return false
    @player2 = ko.computed =>
      return @players()[1] if @players()[1]
      return false

    if game.winner
      winner = new Player(game.winner)
      for player in @players()
        player.winner(true) if player.id() == winner.id()

    @canJoin = ko.computed =>
      !@players()[1] && @players()[0] && !@players()[0].isCurrentPlayer()

    if game.chat_messages && game.chat_messages.length
      for message in game.chat_messages
        @messages.push
          avatar: message.user.avatar
          message: message.message
          username: message.user.name

    if game.moves && game.moves.length
      user_id_cache = {}
      for move in game.moves
        unless user_id_cache[move.user._id]
          player = ko.utils.arrayFirst @players(), (player) =>
            player.id() == move.user._id
          user_id_cache[move.user._id] = player
        @tictactoecubed().move(move.position[0], move.position[1], user_id_cache[move.user._id])

    @start()

    if socket
      socket.on 'connect', =>
        $('#connected').addClass('connected')
          .attr('title', 'Connected!')
          .find('i.icon-remove').removeClass('icon-remove')
            .addClass('icon-ok')
            .addClass('icon-dark')
        $('#chatMessage').removeAttr('disabled')

        socket.emit 'game.enter',
          avatar: user.avatar
          game_id: @id()
          user_id: window.currentUserId
          user_name: user.name

      socket.on 'playerJoined', (user) =>
        @join(user)

      socket.on 'chatMessage', (avatar, username, message) =>
        @messages.push
          avatar: avatar
          message: message
          username: username

      socket.on 'move', (move) =>
        @step(move.position[0], move.position[1], true)

  step: (indexOfTicTacToe, indexOfTicToe, remote = false) ->
    prevPlayer = @currentPlayer()
    prevPlayerIndex = @players.indexOf(prevPlayer)
    nextPlayerIndex = Number !prevPlayerIndex
    nextPlayer = @players()[nextPlayerIndex]
    prevPlayer.turn(false)

    if remote
      @tictactoecubed().move(indexOfTicTacToe, indexOfTicToe, prevPlayer)
    else
      socket.emit 'move',
        game_won: @tictactoecubed().isSolved()
        position: [
          indexOfTicTacToe,
          indexOfTicToe
        ]

    prev_tictactoe = @tictactoecubed().tictactoes()[indexOfTicTacToe[0]][indexOfTicTacToe[1]]
    if @tictactoecubed().isSolved()
      prevPlayer.winner(true)
      prev_tictactoe.highlight(false)
    else
      nextPlayer.turn(true)
      @currentPlayer(nextPlayer)

      tictactoe = @tictactoecubed().tictactoes()[indexOfTicToe[0]][indexOfTicToe[1]]
      @tictactoecubed().activate(false, false)
      if tictactoe.won() || tictactoe.draw()
        @tictactoecubed().activate(nextPlayer.isCurrentPlayer())
        tictactoe.highlight(false)
      else
        prev_tictactoe.highlight(false) if prev_tictactoe.won() || prev_tictactoe.draw()
        tictactoe.active(true) if nextPlayer.isCurrentPlayer()
        tictactoe.highlight(true)

  start: ->
    @state('started')
    if @moves && @moves.length
      lastMove = @moves[@moves.length-1]
      prevPlayer = ko.utils.arrayFirst @players(), (player) ->
        player.id() == lastMove.user._id
      @currentPlayer(prevPlayer)
      @step(lastMove.position[0], lastMove.position[1])
    else
      @currentPlayer(@players()[0])
      @currentPlayer().turn(true)
      @tictactoecubed().activate(@currentPlayer().isCurrentPlayer())

  addPlayer: (player) ->
    player.tic ?= 'x' if @players().length == 0
    player.tic ?= 'o' if @players().length == 1
    @players.push(new Player(player)) if @players().length < 2

  join: (player) ->
    @addPlayer(player)
    @state('waiting') if @players().length == 1
    @start() if @players().length == 2

  getPlayerByTic: (tic) ->
    ko.utils.arrayFirst @players(), (player) ->
      player.tic() == tic

  scrollChat: ->
    $('.chats').prop('scrollTop', $('.chats').prop('scrollHeight'))

  joinGame: (data, event) ->
    if $(event.target).hasClass('disabled')
      event.preventDefault()
      return false
    else
      socket.emit('game.join')
      location.href = @join_url

  sendMessage: (data, event) ->
    target = $(event.target)
    if event.keyCode == 13
      socket.emit('sendMessage', target.val())
      target.val('')
    else
      return true

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
