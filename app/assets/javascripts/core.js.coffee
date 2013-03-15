$.MB ||= {}

$.log = (str) ->
  if $.MB.env == "development"
    console.log(str)