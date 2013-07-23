io = require('socket.io')

mongoose = require('mongoose')
Game = mongoose.model('Game')
User = mongoose.model('User')

module.exports = exports = (server) ->
  sio = io.listen(server)
  sio.sockets.on 'connection', (socket) ->

      socket.on 'game.join', (data) ->
        socket.avatar = data.avatar
        socket.game_id = data.game_id
        socket.channel = 'game:' + data.game_id
        socket.user_id = data.user_id
        socket.user_name = data.user_name
        socket.join socket.channel

        User.findById socket.user_id, (err, user) ->
          if user
            user.online = true
            user.save()


      socket.on 'disconnect', (data) ->
        socket.leave socket.channel
        User.findById socket.user_id, (err, user) ->
          if user
            user.online = false
            user.save()

      socket.on 'sendMessage', (message) ->
        # Send message to everybody including sender
        Game.findById socket.game_id, (err, game) ->
          if game
            game.chat_messages.push
              user: socket.user_id
              message: message
            game.save (err) ->
              unless err
                sio.sockets.in(socket.channel)
                           .emit('chatMessage', socket.avatar, socket.user_name, message)

      socket.on 'move', (move) ->
        # Send move to all except sender
        Game.findById socket.game_id, (err, game) ->
          if game
            game.moves.push
              user: socket.user_id
              position: move
            game.save (err) ->
              unless err
                socket.broadcast.to(socket.channel).emit('move', move)
