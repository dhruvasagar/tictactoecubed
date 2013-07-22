io = require('socket.io')

module.exports = exports = (server) ->
  sio = io.listen(server)
  sio.sockets.on 'connection', (socket) ->

      socket.on 'game.join', (data) ->
        socket.avatar = data.avatar
        socket.game_id = data.game_id
        socket.channel = 'game:' + data.game_id
        socket.username = data.username
        socket.join socket.channel

      socket.on 'disconnect', (data) ->
        socket.leave socket.channel

      socket.on 'sendMessage', (message) ->
        sio.sockets.in(socket.channel)
                   .emit('chatMessage', socket.avatar, socket.username, message)

      socket.on 'move', (move) ->
        socket.broadcast.to(socket.channel).emit('move', move)
