# Description:
#   Tell Hubot to send a user a message when appears (i.e. sends a message) in the room
#
# Dependencies:
#   moment (if HUBOT_TELL_ABSOLUTE_TIME is not set)
#
# Configuration:
#   HUBOT_TELL_ALIASES [optional] - Comma-separated string of command aliases for "tell".
#   HUBOT_TELL_ABSOLUTE_TIME [boolean] - Set to use relative time strings ("2 hours ago")
#
# Commands:
#   hubot tell <recipients> <some message> - tell <recipients> <some message> next time they are present.
#
# Notes:
#   Case-insensitive prefix matching is employed when matching usernames, so
#   "foo" also matches "Foo" and "foooo".
#   A comma-separated list of recipients can be supplied to relay the message
#   to each of them.
#
# Author:
#   christianchristensen, lorenzhs, xhochy, patcon, modified by neson

config =
  aliases: if process.env.HUBOT_TELL_ALIASES?
    # Split and remove empty array values.
    process.env.HUBOT_TELL_ALIASES.split(',').filter((x) -> x?.length)
  else
    []
  relativeTime: !process.env.HUBOT_TELL_ABSOLUTE_TIME?

module.exports = (robot) ->
  commands = ['tell'].concat(config.aliases)
  commands = commands.join('|')

  REGEX = ///(#{commands})\s+([\w,.-@]+):?\s+(.*)///i

  robot.respond REGEX, (msg) ->
    localstorage = JSON.parse(robot.brain.get 'hubot-tell') or {}

    recipients = msg.match[2].replace('@', '').split(',').filter((x) -> x?.length)
    message = msg.match[3]

    room = msg.message.user.room
    tellmessage = [msg.message.user.name, new Date(), message]
    if not localstorage[room]?
      localstorage[room] = {}
    for recipient in recipients
      if localstorage[room][recipient]?
        localstorage[room][recipient].push(tellmessage)
      else
        localstorage[room][recipient] = [tellmessage]
    msg.reply("好，下次 #{recipients.join('、')} 出現的時候我會跟他說「#{message}」。")
    robot.brain.set 'hubot-tell', JSON.stringify(localstorage)
    robot.brain.save()
    return

  # When a user appears, check if someone left them a message
  robot.hear /.*/i, (msg) ->
    localstorage = JSON.parse(robot.brain.get 'hubot-tell') or {}

    if config.relativeTime
      moment = require('moment')
      moment.locale('zh-TW')
    username = msg.message.user.name
    room = msg.message.user.room
    if localstorage[room]?
      for recipient, message of localstorage[room]
        # Check if the recipient matches username
        if username.match new RegExp("^#{recipient}$", "i")
          tellmessage = "#{username}: "
          for message in localstorage[room][recipient]
            # Also check that we have successfully loaded moment
            if config.relativeTime && moment?
              timestr = moment(message[1]).fromNow()
            else
              timestr = "#{message[1].toLocaleString()}"
            tellmessage += "#{message[0]} 在 #{timestr} 要我跟你說：「#{message[2]}」。\r\n"
          delete localstorage[room][recipient]
          robot.brain.set 'hubot-tell', JSON.stringify(localstorage)
          robot.brain.save()
          msg.send(tellmessage)
    return
