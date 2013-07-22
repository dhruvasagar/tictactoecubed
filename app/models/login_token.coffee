module.exports = (Schema) ->
  LoginToken = new Schema
    email: 
      type: String
      index: true
    series:
      type: String
      index: true
    token:
      type: String
      index: true

  LoginToken.method 'randomToken', ->
    Math.random((new Date().valueOf() * Math.random())) + ''

  LoginToken.virtual('cookieValue')
    .get ->
      JSON.stringify
        email: @email
        token: @token
        series: @series

  LoginToken.pre 'save', (next) ->
    @token = @randomToken()
    @series = @randomToken() if @isNew
    next()

  LoginToken
