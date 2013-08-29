class @Message
  constructor: (message, avatar=null, user_name=null) ->
    @avatar = ko.observable(message.user.avatar || avatar)
    @message = ko.observable(message.message)
    @username = ko.observable(message.user.name || user_name)
    @created_at = new Date(message.created_at)

    @timestamp = ko.computed =>
      moment(@created_at).fromNow()
