class @Message
  constructor: (message, avatar=null, user_name=null) ->
    @avatar = ko.observable(message.user.avatar || avatar)
    @message = ko.observable(message.message)
    @username = ko.observable(message.user.name || user_name)
    @created_at = ko.observable(message.created_at)

    @timestamp = ko.computed =>
      moment().zone(@created_at()).fromNow()
