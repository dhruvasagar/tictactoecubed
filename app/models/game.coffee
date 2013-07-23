game_states = 'new waiting started forfeited finished'.split(' ')

module.exports = exports = (Schema, Move, ChatMessage) ->
  Game = new Schema
    turn:
      type: Schema.ObjectId
      ref: 'User'
    winner:
      type: Schema.ObjectId
      ref: 'User'
    players: [
      type: Schema.ObjectId
      ref: 'User'
    ]
    state:
      type: String
      enum: game_states
      default: 'new'
    moves: [Move]
    chat_messages: [ChatMessage]

  Game.method 'setState', (state) ->
    @state = state

  Game.method 'start', ->
    @setState('started')

  Game.method 'waiting', ->
    @setState('waiting')

  Game.method 'forfeit', ->
    @setState('forfeited')

  Game.method 'finish', ->
    @setState('finished')

  Game.method 'join', (userId)->
    if @players.length == 0
      @players.push(userId)
      @waiting()
    else if @players.length < 2
      if @players[0] != userId
        @players.push(userId) 
        @start()

  Game.method 'chat', 

  Game.pre 'save', (next) ->
    if @players.length <= 2
      next()
    else
      next(new Error('Too many players'))

  Game
