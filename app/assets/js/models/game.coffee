class @Game
  constructor: (game, socket) ->
    @id = ko.observable(game._id)
    @state = ko.observable(game || 'new')
    @players = ko.observableArray([])
    @messages = ko.observableArray([])
    @currentPlayer = ko.observable()
    @tictactoecubed = ko.observable(new TicTacToeCubed(this))

    @start = =>
      @state('started')
      @currentPlayer(game.turn || @players()[0])
      @currentPlayer().turn(true)
      @tictactoecubed().activate() if @currentPlayer().isCurrentPlayer()

    @join = (player) =>
      player.tic ?= 'x' if @players().length == 0
      player.tic ?= 'o' if @players().length == 1
      @players.push(new Player(player)) if @players().length < 2
      @state('waiting') if @players().length == 1
      @start() if @players().length == 2

    if game and Object.prototype.toString.call(game.players).match('Array')
      for player in game.players
        @join player

    if game and Object.prototype.toString.call(game.chat_messages).match('Array')
      for message in game.chat_messages
        @messages.push
          avatar: message.user.avatar
          message: message.message
          username: message.user.name

    @player1 = ko.computed =>
      return @players()[0] if @players()[0]
      return false
    @player2 = ko.computed =>
      return @players()[1] if @players()[1]
      return false

    @canJoin = ko.computed =>
      !@players()[1] && @players()[0] && @players()[0].isCurrentPlayer()

    @getPlayerByTic = (tic) =>
      ko.utils.arrayFirst @players(), (player)=>
        player.tic() == tic

    @step = (indexOfTicTacToe, indexOfTicToe, remote = false) =>
      if remote
        @tictactoecubed().move(indexOfTicTacToe, indexOfTicToe, @currentPlayer())
      else
        socket.emit 'move',
          player: @currentPlayer()
          indexOfTicToe: indexOfTicToe
          indexOfTicTacToe: indexOfTicTacToe

      prevPlayer = @currentPlayer()
      prevPlayerIndex = @players.indexOf(prevPlayer)
      nextPlayerIndex = Number !prevPlayerIndex
      nextPlayer = @players()[nextPlayerIndex]

      prevPlayer.turn(false)
      nextPlayer.turn(true)

      @currentPlayer(nextPlayer)

      @tictactoecubed().activate(false)
      @tictactoecubed().tictactoes()[indexOfTicToe[0]][indexOfTicToe[1]].active(true) if nextPlayer.isCurrentPlayer()

    socket.on 'connect', =>
      $('#connected').addClass('connected')
        .attr('title', 'Connected!')
        .find('i.icon-remove').removeClass('icon-remove')
          .addClass('icon-ok')
          .addClass('icon-dark')
      $('#chatMessage').removeAttr('disabled')

      socket.emit 'game.join',
        avatar: user.avatar,
        game_id: @id()
        user_id: window.currentUserId
        user_name: user.name

    socket.on 'chatMessage', (avatar, username, message) =>
      @messages.push
        avatar: avatar,
        message: message,
        username: username
      $('.chats').prop('scrollTop', $('.chats').prop('scrollHeight'))

    socket.on 'move', (move) =>
      @step(move.indexOfTicTacToe, move.indexOfTicToe, true)
