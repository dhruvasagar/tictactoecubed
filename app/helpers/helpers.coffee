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
  res.locals.activeNav = (href) ->
    if req.session.currentUserId
      if ( req.path.match('dashboard') && href == 'dashboard') || ( req.path.match('games') && href == 'games' )
        return 'active'
    else
      if ( req.path.match('about') && href == 'about' ) || ( req.path.match('contact') and href == 'contact' )
        return 'active'
    return ''

module.exports = exports = (req, res) ->
  activeNav req, res
  capitalize req, res
  currentUser req, res
  flashSetter req, res
  flashMessage req, res
