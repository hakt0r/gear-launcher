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
  # return n if n = ICON[pkg]
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
