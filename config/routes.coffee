passport = require('passport')
middlewares = require('./middlewares')

exports.registerRoutes = (app) ->
  controllers = require('../app/controllers')

  app.get '/', controllers.home.index
  app.get '/about', controllers.home.about
  app.get '/contact', controllers.home.contact
  app.post '/contact', controllers.home.contact

  app.get '/dashboard', middlewares.authenticateUser, controllers.home.dashboard

  app.get '/sessions/new', controllers.sessions.new
  app.post '/sessions', controllers.sessions.create
  app.del '/sessions', middlewares.authenticateUser, controllers.sessions.delete

  app.get '/auth/facebook', passport.authenticate('facebook',
    scope: [
      'email'
      'publish_stream'
    ]
  )
  app.get '/auth/facebook/callback', passport.authenticate('facebook',
    failureRedirect: '/sessions/new'
  ), controllers.auth.callback

  app.get '/auth/github', passport.authenticate('github')
  app.get '/auth/github/callback', passport.authenticate('github',
    failureRedirect: '/sessions/new'
  ), controllers.auth.callback

  app.get '/auth/google', passport.authenticate('google',
    scope: [
      'https://www.googleapis.com/auth/userinfo.email'
      'https://www.googleapis.com/auth/userinfo.profile'
    ]
  )
  app.get '/auth/google/callback', passport.authenticate('google',
    failureRedirect: '/sessions/new'
  ), controllers.auth.callback

  app.get '/users/new', controllers.users.new
  app.post '/users', controllers.users.create
  app.get '/users/:id', middlewares.authenticateUser, middlewares.confirmSelf, controllers.users.show
  app.get '/users/:id/edit', middlewares.authenticateUser, middlewares.confirmSelf, controllers.users.edit
  app.post '/users/:id', middlewares.authenticateUser, middlewares.confirmSelf, controllers.users.update

  app.get '/games', middlewares.authenticateUser, controllers.games.index
  app.get '/games/new', middlewares.authenticateUser, controllers.games.new
  app.post '/games', middlewares.authenticateUser, controllers.games.create
  app.get '/games/:id', middlewares.authenticateUser, controllers.games.show
  app.get '/games/:id/join', middlewares.authenticateUser, controllers.games.join
  app.get '/games/:id/observe', middlewares.authenticateUser, controllers.games.observe
