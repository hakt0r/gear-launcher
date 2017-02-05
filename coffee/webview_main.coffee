unless API? then window.API = {
  isTouchDevice: no
  focus:->
  showKeyboard:->
  hideKeyboard:->
  getApps: -> JSON.stringify ['com.android.browser','com.android.dialer']
  getAppName: (p)-> x = "com.android.browser":"Browser", "com.android.dialer":"Phone", 'script.test123':"Test Script"; x[p]
  getAppIcon: (p)-> null
  getTasks: -> JSON.stringify ['{com.android.browser/fefe}']
  getScripts: -> JSON.stringify ['test123']
  toast: -> console.log 'toast', arguments[0]
  notify: -> console.log 'notify', arguments[0]
  launch: -> console.log 'launch', arguments[0] }
else
  API.isTouchDevice = yes

API.appIcon = (pkg) ->
  return n if n = ICON[pkg]
  ICON[pkg] = n = API.getAppIcon pkg
  do API.saveAppIcons
  n

API.saveAppIcons = ->
  return if API.saveAppIcons.lock is true
  API.saveAppIcons.lock = true
  setTimeout ( -> localStorage.setItem 'app_icon', JSON.stringify ICON; API.saveAppIcons.lock = false ), 100
  null

API.appName = (pkg) ->
  return n if n = NAME[pkg]
  return pkg.replace(/script./,'') if pkg.match /^script/
  n = API.getAppName pkg
  API.saveAppName pkg, ( if "Unknown" is n then basename pkg else n )
  return n

API.saveAppName = (pkg,name)->
  return if API.saveAppName.lock is true
  API.saveAppName.lock = true
  setTimeout ( -> localStorage.setItem 'app_name', JSON.stringify NAME; API.saveAppName.lock = false ),100
  NAME[pkg] = name

API.saveAppPrefs = ->
  return if API.saveAppPrefs.lock is true
  API.saveAppPrefs.lock = true
  setTimeout ( -> localStorage.setItem 'app_prefs', JSON.stringify PREFS; API.saveAppPrefs.lock = false ),100
  null




window.PREFS = try JSON.parse localStorage.getItem('app_prefs') || {} catch e then {}
window.NAME  = try JSON.parse localStorage.getItem('app_name')  || {} catch e then {}
window.ICON  = try JSON.parse localStorage.getItem('app_icon')  || {} catch e then {}

basename = (a)-> a.replace(/.*\./,'')




Button = (opts)->
  b = $  "<a class=\"btn #{opts.class || ''}\" href=\"#\"><span>#{opts.name}<span></a>"
  if opts.icon
    if opts.icon.substr(0,3) is 'fa-' then b.prepend $ """<i class="fa #{opts.icon} fa-2x"></i>"""
    else b.prepend $ """<img src="#{opts.icon}"/>"""
  Button.click b, opts.click if opts.click?
  b.attr 'state', state if opts.state?
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




class Menu
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
  $("#launch").css 'paddingBottom', $("#actions").height() + 'px'
  window.MAIN = new Menu id:'main', title:'g.e.a.r.', items:
    reload: title:"reload", icon:"fa-reload", click:(e)-> window.location = "?reload"
  MAIN.show()




App = (pkg,opts={})->
  active = opts.active || false
  toggle = opts.toggle || false
  hide = if opts.hide? then opts.hide else App.prefs.get(pkg,'hide') is true
  name = API.appName pkg
  if ( exists = ( link = App.list[pkg] )? ) is false
    ico = 'fa-dollar' unless ( ico = API.appIcon pkg ) isnt '' and ico isnt null
    App.list[pkg] = link = Button class:'app', name:name, icon:ico
  link.attr "icon",   ico isnt ''
  link.attr "toggle", toggle
  link.attr "active", active
  link.attr "pkg",    pkg
  link.attr "name",   name
  link.attr "hide",   hide
  App.prefs.set pkg, hide:false unless hide
  $("#launch").append(link) unless exists
  link

App.list = {}

App.launchCallback = (pkg)-> ->
  if pkg.match /^script/ then API.runScript pkg.replace /^script./,''
  else API.launch pkg




class Mode
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

class App.hide extends Mode
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

class App.hideIcons
  constructor:->
    @iconsHide = App.prefs.get 'app', 'hide_icons', false
    @namesHide = App.prefs.get 'app', 'hide_names', false
    MAIN.add 'names', key: 'hide_names', title: 'names', icon: 'fa-paragraph', state:@namesHide, click: => @toggle 'names'
    MAIN.add 'icons', key: 'hide_icons', title: 'icons', icon: 'fa-picture-o', state:@iconsHide, click: => @toggle 'icons'
    @sanityCheck 'icons' # if in doubt, show nice icons
    @apply()
  sanityCheck:(which)->
    return unless true is @iconsHide and true is @namesHide
    @namesHide = false if which is 'icons'
    @iconsHide = false if which is 'names'
  apply:->
    l = $('#launch')
    if @iconsHide then l.addClass 'hideicons' else l.removeClass 'hideicons'
    if @namesHide then l.addClass 'hidenames' else l.removeClass 'hidenames'
    App.prefs.set 'app', hide_names: @namesHide
    App.prefs.set 'app', hide_icons: @iconsHide
  toggle:(which)->
    @iconsHide = not @iconsHide if 'icons' is which
    @namesHide = not @namesHide if 'names' is which
    @sanityCheck which
    do @apply

class App.kill extends Mode
  title: 'kill'
  icon:'fa-kill'
  activate:->
    $('a.btn.app').each (idx,me)-> me = $ me; Button.click me, (e)->
        API.toast 'kill ' + me.attr 'pkg'
        API.kill(pkg)
  deactivate:->

class App.rename extends Mode
  title: 'rename'
  icon:'fa-pencil'
  activate:->
    $('#launch').addClass 'unhide'
    $('a.btn.app').each (idx,me)-> me = $ me; Button.click me, (e)->
        API.toast 'rename ' + me.attr 'pkg'
  deactivate:-> $('#launch').removeClass 'unhide'

App.onResize = -> call key for k, call of App.onResize.list
App.onResize.list = {}
$ -> $(window).on 'resize', App.onResize

App.prefs = {}
App.prefs.set = (pkg,opts)->
  o = window.PREFS[pkg] || window.PREFS[pkg] = {}
  o[k] = v for k,v of opts
  do API.saveAppPrefs
  o

App.prefs.get = (pkg,key,def)->
  o = window.PREFS[pkg] || window.PREFS[pkg] = {}
  if o[key] then o[key] else if def? then def else

if null is PREFS then API.toast "FAIL!!"

App.list = ->
  for l in JSON.parse API.getApps()
    App l, active: false
  null

App.scripts = ->
  for l in JSON.parse API.getScripts()
    if l.match(/\.start$/) or l.match(/\.stop$/)
      name = l.replace(/\.start$/,'').replace(/\.stop$/)
      App 'script.' + name, toggle:true, active:false
    else App 'script.' + l, active:false
  null

App.running = ->
  $('a.app').removeClass 'down'
  for l in JSON.parse API.getTasks()
    [ proc, activity ] = l.replace("{",'').replace("}",'').split('/')
    App proc, active: true
  null

clock = ->
  c = $ "<div id=clock>00:00:00<div>"
  $("head").append """<style>#clock{position:fixed;top:0;left:0;color:#555;font-size:72px;z-index:-1;width:100%;text-align:center;}</style>"""
  $("body").prepend c
  c.text ( new Date ).toTimeString().replace(/\ .*/,'')
  timer = null
  disengage = -> clearInterval timer; console.log 'disengaged'
  do engage = ->
    console.log 'engaged'
    timer = setInterval ( -> requestAnimationFrame ->
      c.text ( new Date ).toTimeString().replace(/\ .*/,'')
      do App.running
  ), 1000
  w =  $ window
  w.on 'invisible',  disengage
  w.on 'visible', engage
  c

class window.Sort
  id:'default'
  constructor:->
    Sort[@id] = @
  activate:->
    return if Sort.lock is true
    Sort.current = @
    Sort.lock = true
    @timer = setTimeout ( => do @apply; Sort.lock = false ), 10
    null
  apply:->
    items = $("#launch > a")
    sorted = $ ( items.sort (a,b)->
      sa = parseInt(a.getAttribute 'score'); sb = parseInt(b.getAttribute 'score')
      ( return if sa is sb then 0 else if sa > sb then -1 else 1 ) if sa > -1 and sb > -1
      ah = a.getAttribute('hide');  bh = b.getAttribute('hide')
      return  1 if ah is 'true' and bh isnt 'true'
      return -1 if bh is 'true' and ah isnt 'true'
      return a.name.localeCompare(b.name) )
    $('#launch').append sorted





class App.shell extends Mode
  title: 'shell'
  icon: 'fa-dollar'
  constructor:->
    App.onResize['shell'] = ->
      a.css "width", ( w.width() - 10 ) + 'px'
    @activate = ->
      w.css 'display', 'initial'
      $("#shell textarea").focus();
      API.showKeyboard()
      $("#launch").css 'paddingTop', w.height() + 'px'
      do App.onResize['shell']
    @deactivate = =>
      @field$.val('')
      $("#launch").css 'paddingTop', '100px'
      w.css 'display', 'none'; API.hideKeyboard()
      $("#launch>a").each (k,a)-> a.setAttribute 'score', null
      do App.onResize['shell']
    $("head").append w = $ """<style>
      #shell { width:100%; position: fixed; top: 0; left:0; height: 15%; min-height: 15%; background: rgba(64,0,0,.9); }
      #shell textarea { position: absolute; bottom: 5px; left:5px; top:5px; right:10px; text-align: left; color:#555;font-size:12px;
      background: rgba(64,0,0,.9); };
    </style>"""
    $("body").append w = $ """<div id=shell style="display:none"></div>"""
    super

    @kmap = {}
    w.append a = @field$ = $ """<textarea type=text></textarea>"""
    @field$.on 'keydown', (evt)=>
      seq =
        ( if evt.shiftKey then 'S' else '' ) +
        ( if evt.ctrlKey  then 'C' else '' ) +
        ( if evt.altKey   then 'A' else '' ) +
        evt.keyCode
      clearTimeout @timer if @timer
      console.log 'key', evt.keyCode, seq, @kmap[seq]
      return evt.preventDefault() if ( fn = @kmap[seq] ) and not fn() is true
      @kmap.default()
    @field$.on   'blur',  => @field$.focus()
    @field$.focus()
    $(window).on 'focus', => @field$.focus()
    $(window).on 'blur',  => @field$.focus()

    @default = (e)=> @default.action = true
    @field$.on 'keyup', =>
      return unless @default.action
      @default.action = false
      matches = @fuzzy pattern: @field$.val(), index: $("#launch>a").toArray().map (a)-> { item:a, full: a.getAttribute('name') }
      matches.forEach (i)-> $(i.item).attr('score',i.score)
      matches.forEach (i)-> console.log i.score, $(i.item).attr('score',i.score)
      Sort.current.apply()

    @bind
      9:   @next          # tab
      32:  @commitString  # space
      S9:  @commit        # shift-tab
      S32: @default       # shift-space
      27:  @resetHide     # esc
      C67: @reset         # ctrl-c
      10:  @launch        # enter
      13:  @launch        # return
      39:  @commit        # right
      38:  @prev          # up
      40:  @next          # down
      C38: @histPrev      # up
      C40: @histNext      # down
      S38: @first         # shift-up
      S40: @last          # shift-down
      default: @default
    null
  null:->
  bind: (seq,fnc)->
    fnc = fnc || -> console.log 'kbd.combo', seq
    return @kmap[seq] = fnc.bind @ unless typeof seq is 'object'
    @bind k,v for k,v of seq
    null

  launch:->
    pkg = $('#launch a:first').attr('pkg')
    do App.launchCallback pkg
    @toggle()

  fuzzy: (opts)->
    { pattern, index, token, multi } = opts
    token = new Array index.length unless token
    multi = new Array index.length unless multi
    plen = ( pattern = pattern.toLowerCase() ).length
    index.forEach (item,k)->
      mlen = ( matchee = item.full.toLowerCase() ) .length
      i = j = 0; h = 5
      score = 5 - Math.min 5, Math.abs( plen - mlen )
      while i < mlen and j < plen
        if matchee[i] is pattern[j]
          j += 1
          h += 1 + h
        else h = 0
        score += h
        i++
      item.score = ( score + ( token[k] || 0 ) ) * ( multi[k] || 1 )
    index.sort (a,b)-> b.score - a.score

$ -> requestAnimationFrame ->
  do Menu.init
  do App.list
  do App.scripts
  Sort.current = Sort.default = new Sort
  Mode.default = new Mode.launch menu:false
  Mode.default.toggle()
  new App.shell
  new App.rename
  new App.hide
  new App.hideIcons
  do clock
  API.notify 1, "gear started", 'android not so sucky after all?'
  API.callbackTest()
