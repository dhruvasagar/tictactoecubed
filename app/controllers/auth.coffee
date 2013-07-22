module.exports = exports =
  callback: (req, res) ->
    if req.user
      req.session.currentUserId = req.user.id
      req.session.currentUserEmail = req.user.email
    res.redirect '/'
