module.exports = exports = (Schema) ->
  ChatMessage = new Schema
    user:
      type: Schema.ObjectId
      ref: 'User'
    message: String

  ChatMessage
