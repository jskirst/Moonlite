$.MB ||= {}

$.log = (str) ->
  if $.MB.env == "development"
    if console
      if console.log
        console.log(str)

# http://stackoverflow.com/questions/6140632/how-to-handle-tab-in-textarea
# Slightly modified - changed insertion of '\t' to double space
$.MB.capture_tabs = ->
  # $("textarea").keydown (e) ->
  #   if e.keyCode == 9
  #     start = this.selectionStart
  #     end = this.selectionEnd
  # 
  #     $this = $(this)
  #     value = $this.val()
  # 
  #     $this.val(value.substring(0, start)+ "  "+ value.substring(end))
  # 
  #     this.selectionStart = this.selectionEnd = start + 2
  # 
  #     e.preventDefault()