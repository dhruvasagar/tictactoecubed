nconf = require('nconf')
mailer = require('nodemailer')

transport = mailer.createTransport 'SMTP',
  service: 'mailjet'
  auth:
    user: nconf.getByEnv('mail:smtp:username')
    pass: nconf.getByEnv('mail:smtp:password')

module.exports = exports =
  sendContactEmail: (params)->
    transport.sendMail
      from: 'no-reply@tictactoecubed.com'
      to: 'contact@tictactoecubed.com'
      cc: params.email
      subject: params.subject
      text: params.message
    , (err, res) ->
      console.log err if err
