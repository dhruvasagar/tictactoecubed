class @Player
  constructor: (playerData) ->
    @id = ko.observable(playerData._id)
    @tic = ko.observable(playerData.tic || 'x')
    @turn = ko.observable(false)
    @name = ko.observable(playerData.name || 'Player')
    @avatar = ko.observable(playerData.avatar || 'http://www.gravatar.com/avatar' )

    @isCurrentPlayer = ko.computed =>
      return @id() == window.currentUserId
