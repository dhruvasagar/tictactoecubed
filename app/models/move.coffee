module.exports = exports = (Schema) ->
  Move = new Schema
    player:
      type: Schema.ObjectId
      ref: 'User'
    position: []
