User = require('mongoose').model('User')

module.exports =
  new: (req, res) ->
    res.render 'users/new',
      user: new User()

  create: (req, res) ->
    user = new User(req.body.user)

    user.save (err) ->
      if err
        res.render 'users/new',
          user: user
      else
        req.session.currentUserId = user.id
        req.session.currentUserEmail = user.email
        req.flash 'info', 'Your account has been created'
        res.redirect '/'

  show: (req, res) ->
    User.findById req.param('id'), (err, user) ->
      if user
        res.render 'users/show',
          user: user
      else
        req.flash 'error', 'Invalid User'
        res.redirect '/'
    return

  edit: (req, res) ->
    User.findById req.param('id'), (err, user) ->
      if user
        res.render 'users/edit',
          user: user
      else
        req.flash 'error', 'Invalid User'
        res.redirect '/'
    return

  update: (req, res) ->
    User.findById req.param('id'), (err, user) ->
      if user
        user.update req.body.user, (err) ->
          if err
            req.flash 'error', 'Unable to update Account'
            res.render 'users/edit',
              user: user
          else
            req.flash 'success', 'Profile Updated'
            res.redirect '/'
    return
