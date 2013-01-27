class Page extends Backbone.Model
  #id
  #title
  #featured_image_id
  #html
  #views
  #published
  #keywords
  #description


  idAttribute: '_id'

  featured_image_url: ->
    @get('featured_image')?.image.featured.url

  thumb_image_url: -> 
    @get('featured_image')?.image.character_thumb.url


  state: ->
    if @get('published') then 'Published' else 'Hidden'


Character.Pages.Page   = Page



class Pages extends Backbone.Collection
  model: Page
  url: '/admin/character/pages'


Character.Pages.Pages  = Pages

