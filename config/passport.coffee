nconf = require('nconf')
passport = require('passport')
User = require('mongoose').model('User')

Strategies =
  'github': require('passport-github').Strategy
  'google': require('passport-google-oauth').OAuth2Strategy
  'facebook': require('passport-facebook').Strategy

exports.registerStrategies = ->

  passport.serializeUser (user, done) ->
    done(null, user._id)

  passport.deserializeUser (id, done) ->
    User.findById id, (err, user) ->
      done(err, user)

  strategyCallback = (provider) ->
    (accessToken, refreshToken, profile, done) ->
      User.findOrCreateByProvider provider, profile, (err, user) ->
        if user
          user.findOrCreateServiceByProvider provider,
            uid: profile.id
            access_token: accessToken
            refresh_token: refreshToken
          , (err, user) ->
            done(err, user)
        else
          done(err, user)

  for provider, Strategy of Strategies
    passport.use new Strategy
      clientID: nconf.getByEnv('oauth:' + provider + ':id')
      clientSecret: nconf.getByEnv('oauth:' + provider + ':secret')
      callbackURL: nconf.getByEnv('oauth:' + provider + ':callback_url')
    , strategyCallback(provider)
