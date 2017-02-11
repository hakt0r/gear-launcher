###
 * Copyright (C) 2017 Sebastian Glaser <anx@ulzq.de>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 3
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
###

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
    ), 10; action e
    null
  else b.on 'click', ( (e)-> e.preventDefault(); action arguments[0]; )
  null



window.Menu = class Menu
  constructor: (opts)->
    Menu[@id] = @
    @frame$ = $ """<div id="menu_#{opts.id}" class="launcher actions menu"></div>"""
    @frame$.hide()
    $('#actions').append @frame$
    @item = {}
    @add k, v for k,v of opts.items
    null
  add:(k,v={})->
    @frame$.append @item[k] = Button name:v.title||k, click:v.click, icon:v.icon
    setTimeout App.onResize, 0
    return @[k]
  remove:->
    do Menu.reset
    do @frame$.remove
  activate:->
    try Menu.current.hide()
    Menu.current = @
    @active = yes
    @frame$.show()
  deactivate:->
    @active = no
    @frame$.hide()
  show:->
    do @activate
    do Menu.show
  hide:->
    do @deactivate
    do Menu.reset

Menu.show = ->
  @active = yes; @frame$.show()
  do App.onResize
Menu.hide = ->
  @active = no;  @frame$.hide() #; @reset()
  do App.onResize
Menu.toggle = -> if @active then @hide() else @show()
Menu.reset = -> if Menu.current isnt MAIN
  dontHideMenuBar = ( Menu.current || dontHideMenuBar:false ).dontHideMenuBar
  try
    unless dontHideMenuBar
      do Menu.hide
      @active = no
    do Menu.current.deactivate
  do MAIN.activate
  Menu

Menu.init = ->
  Menu.frame$ = $('#actions')
  window.MAIN = Menu.current = new Menu id:'main', title:'g.e.a.r.', items:
    reload: title:"reload", icon:"fa-refresh", click:(e)-> window.location = "?reload"
  window$.on 'menu_key', -> Menu.toggle()
  do App.onResize



window.Dialog = class Dialog
  constructor:(opts={})->
    @[k] = v for k,v of opts
    @title = @title || "Untitled"
    $('body').append @frame$ = $ """<div class=dialog></div>"""
    @frame$.append @title$ = $ """<div class=title>#{@title}</div>"""
    @frame$.append @body$ = $ """<div class=body></div>"""
    @menu = new Menu title:@title, id:@id, items:
        close: title:"close", icon:"fa-window-close", click: => do @remove
    do @menu.show
    do @show
  remove:->
    do @hide
    do @frame$.remove
  show:->
    App.shell.otherFocus = yes
    Dialog.current.hide() if Dialog.current
    Dialog.current = @
    do @frame$.show
  hide:->
    App.shell.otherFocus = no
    Dialog.current = false if Dialog.current is @
    do @frame$.hide
    do @menu.remove

Dialog.current = false

class Dialog.Rename extends Dialog
  constructor:(@pkg,@value)->
    super title: "Rename " + @pkg, id:'rename'
    @type = @type || 'text'
    @body$.append @field$ = $ """<input type="#{@type}" />"""
    @field$.val(@value||'')
    @menu.dontHideMenuBar = yes
    @menu.add 'ok', title:"OK", icon:'fa-check', default:true, click:=>
      NAME[@pkg] = name = @field$.val()
      $("""[pkg="#{@pkg}"]""").attr('name',name)
      $("""[pkg="#{@pkg}"] span""").html(name)
      API.saveAppName @pkg, name
      do @remove
    do @field$.focus
    do API.showKeyboard
    null
  hide:->
    do API.hideKeyboard
    super
