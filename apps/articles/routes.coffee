_ = require 'underscore'
sd = require('sharify').data
Article = require '../../models/article'
Articles = require '../../collections/articles'
embedVideo = require 'embed-video'
{ POST_TO_ARTICLE_SLUGS } = require '../../config'

@magazine = (req, res, next) ->
  new Articles().fetch
    data:
      published: true
      limit: 50
      # Artsy Editorial. TODO: When we launch Writer externally drop this.
      author_id: '503f86e462d56000020002cc'
    error: res.backboneError
    success: (articles) ->
      res.locals.sd.ARTICLES = articles.toJSON()
      res.render 'magazine',
        featuredArticles: articles.featured()
        articlesFeed: articles.feed()

@show = (req, res, next) ->
  new Article(id: req.params.slug).fetchWithRelated
    accessToken: req.user?.get('accessToken')
    error: res.backboneError
    success: (article, author, footerArticles, slideshowArtworks) ->
      res.locals.sd.SLIDESHOW_ARTWORKS = slideshowArtworks?.toJSON()
      res.locals.sd.ARTICLE = article.toJSON()
      res.locals.sd.AUTHOR = author.toJSON()
      res.locals.sd.FOOTER_ARTICLES = footerArticles.toJSON()
      res.render 'show',
        footerArticles: footerArticles.models
        article: article
        slideshowArtworks: slideshowArtworks
        author: author
        embedVideo: embedVideo

@redirectPost = (req, res, next) ->
  console.log typeof POST_TO_ARTICLE_SLUGS, POST_TO_ARTICLE_SLUGS, req.params.id
  return next() unless req.params.id in POST_TO_ARTICLE_SLUGS
  res.redirect "/article/#{req.params.id}"