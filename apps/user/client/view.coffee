_                  = require 'underscore'
sd                 = require('sharify').data
AccountForm        = require './account_form.coffee'
Backbone           = require 'backbone'
GeoFormatter       = require 'geoformatter'
Icon               = require '../../../models/icon.coffee'
LocationSearchView = require '../../../components/location_search/index.coffee'
Profile            = require '../../../models/profile.coffee'
ProfileEdit        = require '../models/profile_edit.coffee'
ProfileForm        = require './profile_form.coffee'
ProfileIconUplaod  = require './profile_icon_upload.coffee'
UserEdit           = require '../models/user_edit.coffee'

module.exports.UserSettingsView = class UserSettingsView extends Backbone.View

  initialize: (options) ->
    @profile     = new Profile sd.PROFILE
    @profileEdit = new ProfileEdit sd.PROFILE
    @$toggleEls = @$ '.garamond-tab, .settings-form'
    @$successMessage = @$ '.settings-success-message'

    window.currentUser = @model

    @profileIconUpload = new ProfileIconUplaod
      el         : @$ '.settings-profile-icon-upload'
      model      : @profile.icon()
      profile    : @profile
      accessToken: @model.get 'accessToken'

    @accountForm = new AccountForm
      el         : @$ '.settings-account-form'
      model      : @model
      profileEdit: @profileEdit

    @profileForm = new ProfileForm
      el      : @$('.settings-profile-form')
      model   : @profileEdit
      userEdit: @model

    # Location Search
    @locationSearchView = new LocationSearchView el: @$('#profile-location')
    @locationSearchView.postRender()
    @listenTo @locationSearchView, 'location:update', @onLocationUpdate

    # On successful posts of either form, show the success message
    @listenTo @model, 'sync', @renderSuccess
    @listenTo @profileEdit, 'sync', @renderSuccess

    @$el.addClass 'is-loaded'

    # Render generic errors like when FB/Twitter OAuth has a problem.
    @renderGenericErrors()

  renderGenericErrors: ->
    support = " Please contact <a href='mailto:support@artsymail.com'>support@artsymail.com</a> for help."
    @$('#settings-generic-error').html (
      if location.search.match 'twitter-already-linked'
        "Twitter account already linked to another Artsy user." + support
      else if location.search.match 'facebook-already-linked'
        "Facebook account already linked to another Artsy user." + support
      else if location.search.match 'could-not-auth'
        "\"Could not authenticate you\" error from our API." + support
    )

  renderSuccess: ->
    $('html,body').animate scrollTop: 0
    @$successMessage.addClass 'is-active'
    _.delay (=> @$successMessage.removeClass('is-active')), 3000

  #
  # Location
  # This is located on the profile form since that is where it is
  # publicly displayed, but we have a location object on the user
  # The current user will set a location object and the profile
  # profile will set a display string for that object.
  #
  onLocationUpdate: (location) ->
    geo = new GeoFormatter location
    @model.save
      location:
        city:        geo.getCity()
        state:       geo.getState()
        state_code:  geo.getStateCode()
        postal_code: geo.getPostalCode()
        country:     geo.getCountry()
        coordinates: geo.getCoordinates()
    @profileEdit.save
      location: @model.location().cityStateCountry()

  events:
    'click .garamond-tab'   : 'onTabClick'
    'click .settings-submit': 'onSubmitButtonClick'

  onTabClick: (event) ->
    return false if $(event.target).is '.is-active'
    @$toggleEls.toggleClass 'is-active'
    @$('form.is-active input:first').focus().blur()
    false

  onSubmitButtonClick: (event) ->
    false


module.exports.init = ->

  new UserSettingsView
    el   : $('#settings')
    model: new UserEdit sd.USER_EDIT
