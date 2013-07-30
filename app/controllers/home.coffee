mailers = require('../mailers')
mongoose = require('mongoose')
Game = mongoose.model('Game')

module.exports =
  about: (req, res) ->
    res.render 'home/about'

  rules: (req, res) ->
    res.render 'home/rules'

  contact: (req, res) ->
    if req.method == 'POST'
      mailers.sendContactEmail
        email: req.param('email')
        subject: req.param('subject')
        message: req.param('message')
      req.flash 'success', 'Message Sent'
      res.redirect '/'
    else
      res.render 'home/contact'

  index: (req, res) ->
    if req.session.currentUserId
      res.redirect '/dashboard'
    else
      res.render 'home/index'

  dashboard: (req, res) ->
    Game.find
      'players': req.session.currentUserId
    .populate('winner players')
    .exec (err, games) ->
      if games
        res.render 'games/index',
          games: games
