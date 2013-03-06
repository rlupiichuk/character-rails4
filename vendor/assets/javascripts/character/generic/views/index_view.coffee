
#    #### ##    ## ########  ######## ##     ## 
#     ##  ###   ## ##     ## ##        ##   ##  
#     ##  ####  ## ##     ## ##         ## ##   
#     ##  ## ## ## ##     ## ######      ###    
#     ##  ##  #### ##     ## ##         ## ##   
#     ##  ##   ### ##     ## ##        ##   ##  
#    #### ##    ## ########  ######## ##     ## 




class IndexView extends Backbone.View
  tagName:    'div'
  id:         'index_view'


  #
  # Resizing min-height of the panels
  #

  resize_panel: (fetch_data) ->
    top_nav_height      = 40
    margin_top_bottom   = 14 * 2
    panel_header_height = 34

    panel_min_height = $(window).innerHeight() - (top_nav_height + margin_top_bottom + panel_header_height) 

    $('.chr-index').css 'min-height', panel_min_height

    paginator_height = 0
    item_height      = 71

    if @options.paginate
      collection = @options.collection()
      collection.paginate.per_page = Math.floor((panel_min_height - paginator_height) / item_height)
    
    $(window).smartresize =>
      @resize_panel(true)


  #
  # Sorting items with Drag'n'Drop
  #

  enable_sorting: ->
    sort_options =
      stop: (e, ui) =>
        ids = this.$('li').map(-> $(this).attr('data-id')).get()        
        $.post "/admin/api/#{ @options.model_slug }/reorder", { _method: 'post', ids: ids }

    $(@items_el).sortable(sort_options).disableSelection()


  #
  # Navigation experience
  #

  action_url: (id) ->
    action_name = @options.render_item_options.action_name ? 'edit'
    "#/#{ @options.scope }/#{ action_name }/#{ id }"


  set_active: (id) ->
    @unset_active()
    $("#index_view a[href='#{ @action_url(id) }']").addClass('active')
    @scroll_to_active()


  unset_active: ->
    $('#index_view a.active').removeClass('active')


  scroll_to_active: ->
    scroll_y = workspace["#{ @options.scope }_index_scroll_y"]
    
    if scroll_y and scroll_y > 0
      window.scroll(0, scroll_y)
    else
      top_offset = $('#index_view a.active').offset().top
      if top_offset - window.scrollY > $(window).height()
        window.scroll(0, top_offset - 100)
  

  lock_scroll: ->
    workspace["#{ @options.scope }_index_scroll_y"] = window.scrollY

    top_bar_height  = $('.top-bar').height()
    app_top_padding = parseInt($('#character').css('padding-top'))

    $(@panel_el).css('top', -window.scrollY + top_bar_height + app_top_padding + 1)
    $(@panel_el).addClass('fixed')


  unlock_scroll: ->
    $(@panel_el).css('top', '').removeClass('fixed')
    window.scroll(0, workspace["#{ @options.scope }_index_scroll_y"])


  scroll_top: ->
    window.scroll(0, 0)


  flush_scroll_y: ->
    workspace["#{ @options.scope }_index_scroll_y"] = 0


  # Options are:
  #   @titlex
  #   @scope
  #   @reorderable
  #   @model_slug
  #   @items ->

  events:
    'keypress #search_input': 'search'


  search: (e) ->
    if e.charCode == 13
      value = $('#search_input').val()
      path  = "#/#{ @options.scope }"
      path  = "#{ path }/s/#{ value }" if value
      workspace.router.navigate(path, { trigger: true })


  initialize: ->
    @render()

    collection = @options.collection()

    collection.search_query = @options.search_query

    collection.on('add',   @add_item,  @)
    collection.on('reset', @add_items, @)
    #collection.on('all',   @render,    @)

    collection.fetch { url: collection.paginate_url() }


  #
  # Rendering
  #

  render: ->
    html = Character.Templates.Index
      title:        @options.title
      searchable:   @options.searchable
      search_query: @options.search_query
      index_url:    "#/#{ @options.scope }"
      new_item_url: "#/#{ @options.scope }/new"

    @$el.html html

    $('#character').append @el

    @panel_el = this.$('.chr-panel')
    @items_el = this.$('ul')

    @resize_panel(false)


  add_item: (model) ->
    # TODO: remove placeholder on adding first item

    item = new Character.IndexItemView
      model:                model
      render_item_options:  @options.render_item_options
      scope:                @options.scope
    
    $(@items_el).append item.el


  render_placeholder: ->
    $(@items_el).append """<li class=chr-placeholder>Nothing is here yet.</li>"""


  add_items: ->
    if @options.items
      objects = @options.items()
    else
      console.error 'IMPORTANT: index view options doesn\'t provide "collection" method!'
      objects = []

    (@render_placeholder() ; return) if objects.length == 0
    
    @add_item(obj) for obj in objects

    # Truncate lines
    $('.chr-line-1 .chr-line-left').trunk8 { lines: 1 }
    $('.chr-line-2 .chr-line-left').trunk8 { lines: 2 }

    # Sorting with drag'n'drop
    @enable_sorting() if @options.reorderable

    # Applying
    $('.chr-index li a').css opacity: 1


Character.IndexView = IndexView




#    #### ######## ######## ##     ## 
#     ##     ##    ##       ###   ### 
#     ##     ##    ##       #### #### 
#     ##     ##    ######   ## ### ## 
#     ##     ##    ##       ##     ## 
#     ##     ##    ##       ##     ## 
#    ####    ##    ######## ##     ## 




class IndexItemView extends Backbone.View
  tagName: 'li'


  render: =>
    action_name = @options.render_item_options.action_name ? 'edit'
    config      = { action_url: "#/#{ @options.scope }/#{ action_name }/#{ @model.id }" }
    
    _.each @options.render_item_options, (val, key) => config[key] = @model.get(val)
    
    html = Character.Templates.IndexItem(config)

    @$el.html html
    @$el.attr('data-id', @model.id)
    return this


  initialize: ->
    @listenTo(@model, 'change',  @render)
    @listenTo(@model, 'destroy', @remove)
    @render()


Character.IndexItemView = IndexItemView

