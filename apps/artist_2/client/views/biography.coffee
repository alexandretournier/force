Backbone = require 'backbone'
ArticleView = require '../../../../components/article/client/view.coffee'
template = -> require('../../../../components/article/templates/index.jade') arguments...
sd = require('sharify').data

module.exports = class BiographyView extends Backbone.View

  initialize: ->
    @listenTo @model.related().articles, 'sync', (@articles) => @render()

  render: ->
    unless @articles?.length
      @$el.html "<div class='loading-spinner'></div>"
      return this
    @$el.html template article: @articles.first(), hideShare: true, hideSubscribe: true
    new ArticleView el: @$el, article: @articles.first()
    this
