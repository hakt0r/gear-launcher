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

unless API? then window.API = {
  isTouchDevice: no
  focus:->
  showKeyboard:->
  hideKeyboard:->
  getApps: -> JSON.stringify ['com.android.browser','com.android.dialer']
  getAppName: (p)-> x = "com.android.browser":"Browser", "com.android.dialer":"Phone", 'script.test123':"Test Script"; x[p]
  getAppIcon: (p)-> null
  getTasks: -> JSON.stringify ['{com.android.browser/fefe}']
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

$::once = (ev,fn)-> $$ = @; @off(ev).on ev, -> fn.apply $$, arguments; $$.off ev

window.window$ = $ window

window$.on 'syskey', (e,key)-> return switch key
  when 'menu' then window$.trigger 'menu_key'
  when 'back' then window$.trigger 'back_key'
  when 'home' then window$.trigger 'home_key'

do API.hideKeyboard
