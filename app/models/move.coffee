module.exports = exports = (Schema) ->
  Move = new Schema
    user:
      type: Schema.ObjectId
      ref: 'User'
    position: []
