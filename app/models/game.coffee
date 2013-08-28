game_states = 'new waiting started forfeited finished'.split(' ')

module.exports = exports = (Schema, Move, ChatMessage) ->
  Game = new Schema
    name: String
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
      @players.push(userId) 
      @start()

  Game.path('moves').validate (moves) ->
    moves.length <= 1 || ( moves.length > 1 &&
      # Last 2 moves shouldn't be the same
      !moves[moves.length-1].equals(moves[moves.length-2]) ) # &&
      # Last move must be according to second last
      # moves[moves.length-1].position[0].toString() ==
      # moves[moves.length-2].position[1].toString() )
  , 'Invalid Move'

  Game.path('winner').validate (winner) ->
    @players.indexOf(winner) >= 0
  , 'Invalid Winner'

  Game.pre 'save', (next) ->
    if @players.length <= 1
      next()
    else if @players.length == 2
      if @players[0].equals(@players[1])
        next(new Error("You can't join your own game"))
      else
        next()
    else
      next(new Error('Game is already full'))

  Game
