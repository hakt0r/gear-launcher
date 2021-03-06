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

window.PREFS = try JSON.parse localStorage.getItem('app_prefs') || {} catch e then {}
window.NAME  = try JSON.parse localStorage.getItem('app_name')  || {} catch e then {}
window.ICON  = try JSON.parse localStorage.getItem('app_icon')  || {} catch e then {}
window.basename = (a)-> a.replace(/.*\./,'')

window.App = (pkg,opts={})->
  name = opts.name || API.appName pkg
  if ( exists = ( link = App.list[pkg] )? ) is false
    ico = 'fa-dollar' unless ( ico = API.appIcon pkg ) isnt '' and ico isnt null
    App.list[pkg] = link = Button class:'app', name:name, icon:ico
  active = opts.active || false
  toggle = opts.toggle || false
  hide = if opts.hide? then opts.hide else App.prefs.get(pkg,'hide') is true
  link.attr "icon",   ico isnt ''
  link.attr "toggle", toggle
  link.attr "active", active
  link.attr "pkg",    pkg
  link.attr "name",   name
  link.attr "hide",   hide
  App.prefs.set pkg, hide:false unless hide
  App.toggle[pkg] = link if toggle is true
  $("#launch").append(link) unless exists
  link

App.list = {}
App.toggle = {}

App.launchCallback = (pkg)-> -> App.launch pkg

App.launch = (pkg)->
  if pkg.match /^script/
    scpt = pkg.replace /^script./,''
    if App.toggle[pkg] then API.runToggle scpt
    else API.runScript scpt
  else API.launch pkg

class App.ViewMode
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
    l = $('.launcher')
    if @iconsHide then l.addClass 'hideicons' else l.removeClass 'hideicons'
    if @namesHide then l.addClass 'hidenames' else l.removeClass 'hidenames'
    App.prefs.set 'app', hide_names: @namesHide
    App.prefs.set 'app', hide_icons: @iconsHide
  toggle:(which)->
    @iconsHide = not @iconsHide if 'icons' is which
    @namesHide = not @namesHide if 'names' is which
    @sanityCheck which
    do @apply


window$.on 'resize', App.onResize = -> call key for key, call of App.onResize.list
App.onResize.list = {}

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
    if l.match /^script\./
      name = l.replace(/\.(toggle|script)$/,'').replace(/^script\./,'')
      if l.match(/\.toggle$/)
        App l, toggle:true, active:false, name:name
      else App l, active:false
    else App l, active: false
  null

App.running = ->
  $('a.app').attr 'active', false
  for l in JSON.parse API.getTasks()
    [ proc, activity ] = l.replace("{",'').replace("}",'').split('/')
    App proc, active: true
  null

App.clock = ->
  c = $ "<div id=clock>00:00:00<div>"
  $("head").append """<style>#clock{position:fixed;top:0;left:0;color:#555;font-size:72px;z-index:-1;width:100%;text-align:center;}</style>"""
  $("body").prepend c
  c.text ( new Date ).toTimeString().replace(/\ .*/,'')
  timer = null
  window$.on 'visible', engage = ->
    clearTimeout timer;
    requestAnimationFrame ->
      c.text ( new Date ).toTimeString().replace(/\ .*/,'')
      do App.running
      timer = setTimeout engage, 1000
  window$.on 'invisible', disengage = -> clearTimeout timer; console.log 'disengaged'
  do engage
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
