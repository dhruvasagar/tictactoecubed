crypto = require('crypto')
gravatar = require('gravatar')

module.exports = (Schema, Service) ->
  User = new Schema
    name: String
    email:
      type: String
      unique: true
      required: true
    passwordHash: String
    salt: String
    online:
      type: Boolean
      default: false
    avatar: String
    services: [Service]
    google_id: String
    github_id: String
    facebook_id: String

  User.virtual('password')
    .get ->
      @_password
    .set (password) ->
      @_password = password
      @salt = @makeSalt()
      @passwordHash = @encryptPassword(password)

  User.virtual('passwordConfirmation')
    .get ->
      @_passwordConfirmation
    .set (passwordConfirmation) ->
      @_passwordConfirmation = passwordConfirmation

  User.method 'makeSalt', ->
    Math.round((new Date().valueOf() * Math.random())) + ''

  User.method 'authenticate', (password) ->
    @encryptPassword(password) == @passwordHash

  User.method 'encryptPassword', (password) ->
    crypto.createHmac('sha1', @salt).update(password).digest('hex')

  User.static 'findOrCreateByProvider', (provider, profile, callback) ->
    email = profile.emails[0].value
    query =
      '$or': [
        {email: email}
      ]
    providerQuery = {}
    providerQuery[provider + '_id'] = profile.id
    query['$or'].push providerQuery

    @findOne query, (err, user) =>
      if user
        callback(err, user)
      else
        userHash =
          uid: profile.id
          name: profile.displayName
          email: email
        userHash[provider + '_id'] = profile.id
        @create userHash, (err, user) ->
          callback(err, user)

  User.method 'findOrCreateServiceByProvider', (provider, serviceObj, callback) ->
    serviceExists = false
    for service in @services
      if service.provider == provider
        serviceExists = true
        service.uid = serviceObj.uid
        service.auth_token = serviceObj.auth_token
        service.refresh_token = serviceObj.refresh_token
    unless serviceExists
      @services.push
        uid: serviceObj.uid
        provider: provider
        access_token: serviceObj.auth_token
        refresh_token: serviceObj.refresh_token
    @save (err, user) ->
      callback(err, user)

  User.pre 'save', (next) ->
    @avatar = gravatar.url @email,
      s: '34'
      r: 'pg'
    next()

  User
