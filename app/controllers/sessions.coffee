mongoose = require('mongoose')
User = mongoose.model('User')
LoginToken = mongoose.model('LoginToken')

module.exports =
  new: (req, res) ->
    res.render 'sessions/new',
      user: new User()

  create: (req, res) ->
    User.findOne email: req.body.user.email, (err, user) ->
      if user and user.authenticate(req.body.user.password)
        req.session.currentUserId = user.id
        req.session.currentUserEmail = user.email

        if req.body.remember_me
          loginToken = new LoginToken
            email: user.email
          loginToken.save ->
            res.cookie 'loginToken', loginToken.cookieValue,
              expires: new Date(Date.now() + 2 * 604800000)
              path: '/'
            req.redirect req.session.originalUrl || '/'
        else
          res.redirect req.session.originalUrl || '/'
      else
        req.flash 'error', 'Incorrect Credentials'
        res.redirect '/sessions/new'
    return

  delete: (req, res) ->
    if req.session and req.session.currentUserId
      User.findById req.session.currentUserId, (err, user) ->
        if user
          LoginToken.remove
            email: user.email
      res.clearCookie('loginToken')
      req.session.destroy()
    res.redirect '/sessions/new'
