express = require 'express'
routes = require './routes'

app = module.exports = express()
app.set 'views', __dirname + '/templates'
app.set 'view engine', 'jade'

app.get '/artwork/:id', routes.index
app.get '/artwork/:id/:action', routes.index
app.get '/artwork_2/:id', routes.index
