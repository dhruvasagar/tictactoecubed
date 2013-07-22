module.exports = exports = (Schema, options) ->
  Schema.add
    created_at:
      type: Date
      default: new Date
    updated_at:
      type: Date
      default: new Date

  Schema.pre 'save', (next) ->
    @updated_at = new Date
    next()
