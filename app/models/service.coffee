module.exports = (Schema) ->
  Service = new Schema
    uid: String
    provider: String
    access_token: String
    refresh_token: String
    expires_at: Date

  Service
