Game = require('mongoose').model('Game')

module.exports =
  new: (req, res) ->
    game = new Game()
    game.join req.session.currentUserId
    game.save (err, game) ->
      if game
        res.redirect "/games/#{game.id}"
      else
        res.redirect '/games'

  create: (req, res) ->
    game = new Game(req.body.game)
    game.join req.session.currentUserId

    game.save (err) ->
      if err
        res.render 'games/new',
          game: game
      else
        req.flash 'success', 'Game created'
        res.redirect "/games/#{game.id}"

  show: (req, res) ->
    Game.findById(req.param('id'))
        .populate('turn winner players moves.user chat_messages.user')
        .exec (err, game) ->
          if game
            res.render 'games/game',
              game: game
          else
            req.flash 'error', 'Invalid Game'
            res.redirect '/games'
    return

  join: (req, res) ->
    Game.findById req.param('id'), (err, game) ->
      if game
        game.join req.session.currentUserId
        game.save (err) ->
          if err
            req.flash 'error', err.message
          else
            req.flash 'success', 'Joined Game'
          res.redirect "/games/#{game.id}"
    return

  index: (req, res) ->
    Game.find()
        .sort('-updated_at')
        .populate('turn winner players')
        .exec (err, games) ->
          res.render 'games/index',
            games: games

  observe: (req, res) ->
    Game.findById req.param('id'), (err, game) ->
      if game
        req.flash 'success', 'You are now observing the game'
        res.redirect "/games/#{game.id}"
      else
        req.flash 'error', 'Game not found'
        res.redirect '/games'
    return
