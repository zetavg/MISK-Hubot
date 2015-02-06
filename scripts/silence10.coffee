module.exports = (robot) ->

  robot.hear /^默哀/i, (msg) ->
    msg.send '現在開始默哀'

    setTimeout ->
      msg.send '1'
    , 1000

    setTimeout ->
      msg.send '2'
    , 2000

    setTimeout ->
      msg.send '3'
    , 3000

    setTimeout ->
      msg.send '4'
    , 4000

    setTimeout ->
      msg.send '5'
    , 5000

    setTimeout ->
      msg.send '6'
    , 6000

    setTimeout ->
      msg.send '7'
    , 7000

    setTimeout ->
      msg.send '8'
    , 8000

    setTimeout ->
      msg.send '9'
    , 9000

    setTimeout ->
      msg.send '10'
    , 10000
