mongoose = require('mongoose')
User = mongoose.model('User')

flashSetter = (req, res) ->
  session = req.session
  flash = session.flash || (session.flash = [])

  req.flash = (type, message) ->
    flash.push
      type: type
      message: message

flashMessage = (req, res) ->
  res.locals.flash = req.session.flash.pop()

capitalize = (req, res) ->
  res.locals.capitalize = (value) ->
    value.charAt(0).toUpperCase() + value.slice(1)

currentUser = (req, res) ->
  if req.session.currentUserId
    unless res.locals.currentUser
      User.findById req.session.currentUserId, (err, user) ->
        res.locals.currentUser = user if user

activeNav = (req, res) ->
  if req.session.currentUserId
    if req.path == '/'
      res.locals.activeNav = 'dashboard'
    else if req.path.match 'games'
      res.locals.activeNav = 'games'
  else
    if req.path.match 'about'
      req.locals.activeNav = 'about'
    else if req.path.match 'contact'
      req.locals.activeNav = 'contact'

module.exports = exports = (req, res) ->
  activeNav req, res
  capitalize req, res
  currentUser req, res
  flashSetter req, res
  flashMessage req, res
