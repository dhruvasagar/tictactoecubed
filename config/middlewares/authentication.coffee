mongoose = require('mongoose')
User = mongoose.model('User')
LoginToken = mongoose.model('LoginToken')

authenticateFromLoginToken = (req, res, next) ->
  cookie = JSON.parse(req.cookies.loginToken)

  LoginToken.findOne
    email: cookie.email
    token: cookie.token
    series: cookie.series
  , (err, token) ->
    if !token
      req.session.originalUrl = req.originalUrl
      res.redirect '/sessions/new'
      return

    User.findOne
      email: token.email
      , (err, user) ->
        if user
          res.locals.currentUser = user
          req.session.currentUserId = user.id
          req.session.currentUserEmail = user.email

          token.token = token.randomToken()
          token.save ->
            res.cookie 'loginToken', token.cookieValue,
              expires: new Date(Date.now() + 2 * 604800000)
              path: '/'
            next()
        else
          req.session.originalUrl = req.originalUrl
          res.redirect '/sessions/new'

module.exports = exports = (req, res, next) ->
    if req.session.currentUserId
      User.findById req.session.currentUserId, (err, user) ->
        if user
          res.locals.currentUser = user
          next()
        else
          req.session.originalUrl = req.originalUrl
          res.redirect '/sessions/new'
    else if req.user # passport.js
      res.locals.currentUser = req.user
      req.session.currentUserId = req.user.id
      req.session.currentUserEmail = req.user.email
      next()
    else if req.cookies and req.cookies.loginToken
      authenticateFromLoginToken(req, res, next)
    else
      req.session.originalUrl = req.originalUrl
      res.redirect '/sessions/new'
