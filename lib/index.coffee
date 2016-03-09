_ = require('lodash')
Joi = require('joi')
express = require('express')
csrf = require('csurf')

csrfProtection = csrf({cookie: true})
Router = express.Router()

ErrorFormater = (code, descs)->
  desc = ''
  if _.isArray descs.details
    _.each(descs.details, (it)-> desc += it.message)
  else if _.isString descs
    desc = descs
  return error_no: code, error_desc: 'parameter error: ' + desc

init = (routerConfigs)->
  for route in routerConfigs
    applyRoute route

schemaValidMiddleware = (schema, schemaValidatePos = 'query', errorCode = '-10001')->
  return (req, res, next)->
    validRet = Joi.validate(req[schemaValidatePos], schema(req, Joi), allowUnknown: true)
    if validRet?.error
      res.status(400).send MagicRoute.ErrorFormater(errorCode, validRet.error)
      return

    next()

applyRoute = (routeConfig)->
  return if routeConfig.disable

  if !routeConfig.url || (!_.isString(routeConfig.url) && !_.isArray(routeConfig.url)) ||
     !routeConfig.middleware || (!_.isString(routeConfig.middleware) && !_.isArray(routeConfig.middleware))
    throw new Error('routeConfig invalid error!')

  routeConfig.method ?= 'get'
  routeConfig.method = routeConfig.method.toLowerCase()
  routeConfig.schemaValidatePos ?= 'query'
  routeConfig.enableCsruf ?= true
  routeConfig.disable ?= false

  if _.isString routeConfig.url
    routeConfig.url = [routeConfig.url]
  if _.isString routeConfig.middleware
    routeConfig.middleware = [routeConfig.middleware]

  innerMiddlewareSetted = false
  for url in routeConfig.url
    if _.isFunction(routeConfig.schema) and !innerMiddlewareSetted
      if routeConfig.enableCsruf
        applyMiddleware url, routeConfig.method, csrfProtection

      applyMiddleware url, routeConfig.method, schemaValidMiddleware(routeConfig.schema, routeConfig.schemaValidatePos, routeConfig.errorCode)

      innerMiddlewareSetted = true

    applyMiddleware url, routeConfig.method, routeConfig.middleware

applyMiddleware = (url, method, middlewares)->
  if _.isArray middlewares
    for mw in middlewares
      if _.isString mw
        Router[method] url, require(mw)
      else if _.isFunction mw
        Router[method] url, mw
      else
        console.warn "Router load #{url} unused!"
  else if _.isFunction middlewares
    Router[method] url, middlewares
  else
    console.warn "invalid Router load #{url}!"

MagicRoute = (config)->
  init(config)
  return Router

MagicRoute.ErrorFormater = ErrorFormater

module.exports = MagicRoute
