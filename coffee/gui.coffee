

window.Button = (opts)->
  b = $  "<a class=\"btn #{opts.class || ''}\" href=\"#\"><span>#{opts.name}<span></a>"
  if opts.icon
    if opts.icon.substr(0,3) is 'fa-' then b.prepend $ """<i class="fa #{opts.icon} fa-2x"></i>"""
    else b.prepend $ """<img src="#{opts.icon}"/>"""
  Button.click b, opts.click if opts.click?
  b.attr 'state', state if opts.state?
  b.attr 'icon', opts.icon?
  b

Button.click = (b, action)->
  b.off 'click touchstart'
  if API.isTouchDevice then b.on 'touchstart', (e)->
    e.preventDefault()
    return API.toast 'locked' if Button.lock is true
    $('body').css 'background', 'red'; Button.lock = true
    setTimeout ( (e)->
      $('body').css 'background', 'black'; Button.lock = false
    ), 100; action e
    null
  else b.on 'click', ( (e)-> e.preventDefault(); action arguments[0]; )
  null



window.Menu = class Menu
  constructor: (opts)->
    Menu[@id] = @
    @frame = $ """<div id="menu_#{opts.id}" class="launcher actions menu"></div>"""
    @frame.hide()
    $('#actions').append @frame
    @show = @frame.show.bind @frame
    @hide = @frame.hide.bind @frame
    @add k, v for k,v of opts.items
    null
  add:(k,v={})->
    @frame.append @[k] = Button name:v.title||k, click:v.click, icon:v.icon
    return @[k]

Menu.init = ->
  window.MAIN = new Menu id:'main', title:'g.e.a.r.', items:
    reload: title:"reload", icon:"fa-refresh", click:(e)-> window.location = "?reload"
  MAIN.show()
  do App.onResize.launcher
