class @Game
  constructor: (game, socket) ->
    @id = ko.observable(game._id)
    @state = ko.observable(game || 'new')
    @players = ko.observableArray([])
    @messages = ko.observableArray([])
    @currentPlayer = ko.observable()
    @tictactoecubed = ko.observable(new TicTacToeCubed(this))

    @step = (indexOfTicTacToe, indexOfTicToe, remote = false) =>
      prevPlayer = @currentPlayer()
      prevPlayerIndex = @players.indexOf(prevPlayer)
      nextPlayerIndex = Number !prevPlayerIndex
      nextPlayer = @players()[nextPlayerIndex]

      prevPlayer.turn(false)
      nextPlayer.turn(true)

      @currentPlayer(nextPlayer)

      @tictactoecubed().activate(false)
      @tictactoecubed().tictactoes()[indexOfTicToe[0]][indexOfTicToe[1]].active(true) if nextPlayer.isCurrentPlayer()

      if remote
        @tictactoecubed().move(indexOfTicTacToe, indexOfTicToe, prevPlayer)
      else
        socket.emit 'move',
          user: @currentPlayer().id()
          position: [
            indexOfTicTacToe,
            indexOfTicToe
          ]

    @start = =>
      @state('started')
      if game.moves && game.moves.length
        lastMove = game.moves[game.moves.length-1]
        prevPlayer = ko.utils.arrayFirst @players(), (player) ->
          player.id() == lastMove.user._id
        @currentPlayer(prevPlayer)
        @step(lastMove.position[0], lastMove.position[1])
      else
        @currentPlayer(@players()[0])
        @currentPlayer().turn(true)
        @tictactoecubed().activate() if @currentPlayer().isCurrentPlayer()

    @join = (player) =>
      player.tic ?= 'x' if @players().length == 0
      player.tic ?= 'o' if @players().length == 1
      @players.push(new Player(player)) if @players().length < 2
      @state('waiting') if @players().length == 1
      @start() if @players().length == 2

    if game.players && game.players.length
      for player in game.players
        @join player

    @player1 = ko.computed =>
      return @players()[0] if @players()[0]
      return false
    @player2 = ko.computed =>
      return @players()[1] if @players()[1]
      return false

    @canJoin = ko.computed =>
      !@players()[1] && @players()[0] && !@players()[0].isCurrentPlayer()

    @getPlayerByTic = (tic) =>
      ko.utils.arrayFirst @players(), (player) =>
        player.tic() == tic

    @scrollChat = =>
      $('.chats').prop('scrollTop', $('.chats').prop('scrollHeight'))

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

    @joinGame = (data, event) =>
      if $(event.target).hasClass('disabled')
        event.preventDefault()
        return false
      else
        socket.emit('game.join')
        location.href = '/games/' + @id() + '/join'

    @sendMessage = (data, event) =>
      target = $(event.target)
      if event.keyCode == 13
        socket.emit('sendMessage', target.val())
        target.val('')
      else
        return true

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
