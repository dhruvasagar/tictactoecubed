mongoose = require('mongoose')

exports.defineModels = ->
  Schema = mongoose.Schema

  plugins = require('./plugins')

  Service = require('./service')(Schema)
  Service.plugin plugins.timestamps

  User = require('./user')(Schema, Service)
  User.plugin plugins.timestamps

  Move = require('./move')(Schema)
  Move.plugin plugins.timestamps

  ChatMessage = require('./chat_message')(Schema)
  ChatMessage.plugin plugins.timestamps

  Game = require('./game')(Schema, Move, ChatMessage)
  Game.plugin plugins.timestamps

  LoginToken = require('./login_token')(Schema)

  mongoose.model 'User', User
  mongoose.model 'Game', Game
  mongoose.model 'Service', Service
  mongoose.model 'LoginToken', LoginToken
