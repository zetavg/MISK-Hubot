# Description:
#   Turn a URL into a QR Code
#
# Commands:
#   hubot whoami - Reply effective username
#   hubot 我是誰 - 說出你的名字

module.exports = (robot) ->

  robot.respond /whoami/i, (msg) ->
    msg.send "#{msg.message.user.name}"

  robot.respond /我是誰/i, (msg) ->
    msg.send "#{msg.message.user.name}"
