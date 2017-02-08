
$(window).on 'home_key', -> do App.shell.toggle
$(window).on 'key keydown keyup', ->
  console.log arguments

class Mode.shell extends Mode
  title: 'shell'
  icon: 'fa-dollar'

  constructor:->
    App.shell = @

    $(window).on 'visible invisible resize', @resize = =>
      if @active
        @field$.focus();
        do API.showKeyboard
        @field$.css "width", ( @window$.width() - 10 ) + 'px'
        $("#launch").css 'paddingTop', @window$.height() + 'px'
        $(window).once 'back_key.Shell', @deactivate
      else
        do API.hideKeyboard
        $("#launch").css 'paddingTop', '100px'
        $(window).off 'back_key.Shell'

    @reset = =>
      @field$.val('')
      $("#launch>a").each (k,a)-> a.setAttribute 'score', null

    @activate = =>
      @active = yes
      @window$.css 'display', 'initial'
      do @reset
      do @resize

    @deactivate = =>
      @active = no
      @window$.css 'display', 'none'
      do @reset
      do @resize

    $("head").append @css$ = $ """<style>
      #shell { width:100%; position: fixed; top: 0; left:0; height: 2em; min-height: 2em; background: rgba(64,0,0,.9); }
      #shell textarea { position: absolute; bottom: 5px; left:5px; top:5px; right:10px; text-align: left; color:#555;font-size:12px;
      background: rgba(64,0,0,.9); };
    </style>"""

    $("body").append @window$ = $ """<div id=shell style="display:none"></div>"""

    super

    @kmap = {}

    @window$.append @field$ = $ """<textarea type=text></textarea>"""
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

    @field$.on 'blur',  => @field$.focus()

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

  toggle:-> if @active then do @deactivate else do @activate

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
