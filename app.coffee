http = require('http')
less = require('less')
path = require('path')
util = require('util')
nconf = require('nconf')
express = require('express')
mongoose = require('mongoose')
passport = require('passport')
connectAssets = require('connect-assets')

nconf.argv()
     .env()
     .file({file: 'config/config.json'})
nconf.defaults
  'NODE_ENV': 'development'
nconf.getByEnv = (key) ->
  nconf.get(nconf.get('NODE_ENV') + ':' + key)

app = express()
app.set 'port', nconf.getByEnv('http:port')
app.set 'views', path.join(__dirname, 'app', 'views')
app.set 'view engine', 'jade'
app.set 'db-uri', nconf.getByEnv('db:uri')

app.use express.favicon()
app.use express.logger('dev')
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser()
app.use express.session
  secret: 'secret'
  cookie:
    maxAge: 7 * 24 * 60 * 60 * 1000

app.use require('./app/helpers')

app.use passport.initialize()
app.use passport.session()

app.use app.router

app.use connectAssets
  src: path.join(__dirname, 'app', 'assets')
  dest: path.join(__dirname, 'public')

app.use express.static(path.join(__dirname, "public"))

app.configure 'development', ->
  app.use express.errorHandler()

models = require('./app/models')
models.defineModels ->
  mongoose.connect(app.get('db-uri'))

require('./config/passport').registerStrategies()
require('./config/routes').registerRoutes(app)

server = http.createServer(app)
server.listen app.get('port'), ->
  console.log 'Express server listening on port ' + app.get('port')

require('./config/socketio')(server)
