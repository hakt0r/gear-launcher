window.Mode = class Mode
  constructor: (opts={})->
    @[k] = v for k,v of opts
    return if @menu is false
    ( @menu = @menu || MAIN ).add @title, title:@title, click: @toggle, icon: @icon
  toggle:=>
    if Mode.current is @constructor
      @deactivate()
      Mode.default.activate()
      Mode.current = Mode.default
      $("#mode").html Mode.default.title
    else
      Mode.default.deactivate() if Mode.default
      @activate Mode.current = @constructor
      $("#mode").html @title
    Sort.current.activate()

class Mode.modifier extends Mode
  toggle:=>
    if @active is true then @deactivate @active = false
    else @activate @active = true
    Sort.current.activate()

class Mode.launch extends Mode
  title: "g.e.a.r"
  activate: ->
    MAIN.show()
    do App.running
    do App.scripts
    $('#launch > a').each (idx,el)->
      pkg = el.getAttribute 'pkg'
      Button.click $(el), App.launchCallback pkg
    null
  deactivate:->

class Mode.hide extends Mode
  title: 'hide'
  icon: 'fa-eraser'
  action:(me)-> (e)->
    if true is App.prefs.get me.attr('pkg'), "hide"
      me.attr("hide",false)
      App.prefs.set me.attr('pkg'), hide:false
    else
      me.attr("hide",true)
      App.prefs.set me.attr('pkg'), hide:true
  activate:->
    $('#launch').addClass 'unhide'
    $('a.btn.app').each (idx,me)=> me = $ me; Button.click me, @action(me).bind @
  deactivate:->
    $('#launch').removeClass 'unhide'

class Mode.kill extends Mode
  title: 'kill'
  icon:'fa-kill'
  activate:->
    $('a.btn.app').each (idx,me)-> me = $ me; Button.click me, (e)->
        API.toast 'kill ' + me.attr 'pkg'
        API.kill(pkg)
  deactivate:->

class Mode.rename extends Mode
  title: 'rename'
  icon:'fa-pencil'
  activate:->
    $('#launch').addClass 'unhide'
    $('a.btn.app').each (idx,me)-> me = $ me; Button.click me, (e)->
        API.toast 'rename ' + me.attr 'pkg'
  deactivate:-> $('#launch').removeClass 'unhide'
