$(document).ready ->
  $('#logout').click ->
    $('<form>')
      .attr
        method: 'POST'
        action: '/sessions'
      .hide()
      .append('<input type="hidden"/>')
      .find('input')
        .attr
          name: '_method'
          value: 'delete'
        .end()
      .appendTo('body')
      .submit()
  return
