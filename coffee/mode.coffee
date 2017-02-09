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
      $(window).off('back_key.Mode')
    else
      Mode.default.deactivate() if Mode.default
      @activate Mode.current = @constructor
      $("#mode").html @title
      $(window).once 'back_key.Mode',=> do @toggle
      $(window).trigger 'resize', 'mode', @
    Sort.current.activate()

class Mode.launch extends Mode
  title: "g.e.a.r"
  activate: ->
    MAIN.show()
    do App.running
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
  icon:'fa-close'
  activate:->
    $('#launch').addClass 'activeOnly'
    $('a.btn.app').each (idx,me)-> me = $ me; Button.click me, (e)->
      pkg = me.attr 'pkg'
      API.toast 'kill ' + pkg
      API.kill(pkg)
  deactivate:->
    $('#launch').removeClass 'activeOnly'

class Mode.rename extends Mode
  title: 'rename'
  icon:'fa-pencil'
  activate:->
    $('#launch').addClass 'unhide'
    $('a.btn.app').each (idx,me)-> me = $ me; Button.click me, (e)->
        new Dialog.Rename me.attr('pkg'), me.attr('name')
  deactivate:-> $('#launch').removeClass 'unhide'
