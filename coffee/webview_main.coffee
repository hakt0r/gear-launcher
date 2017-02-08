$ -> requestAnimationFrame ->
  do Menu.init
  do App.list
  do App.running
  Sort.current = Sort.default = new Sort
  Mode.default = new Mode.launch menu:false
  Mode.default.toggle()
  new Mode.shell
  new Mode.rename
  new Mode.hide
  new Mode.kill
  new App.ViewMode
  do App.clock
  API.notify 1, "gear started", 'android not so sucky after all?'
