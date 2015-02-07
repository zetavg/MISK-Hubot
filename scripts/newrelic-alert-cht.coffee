# Description:
#   Notifies about New Relic events via webhook, in friendly Traditional Chinese
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_NEWRELIC_ALERT_CHT_API_KEY - API key in URL while calling this webhook
#   HUBOT_NEWRELIC_ALERT_CHT_DEFAULT_ROOM - The default room to which message should go
#   HUBOT_NEWRELIC_ALERT_CHT_ROOM_POSTFIX
#   HUBOT_NEWRELIC_ALERT_CHT_DEBUG
#
# Commands:
#   hubot newrelic-alert-cht <application_name> to <room_names (split with ',')> - Sets where an app's alert should goes to
#
# URLS:
#   POST /hubot/newrelic-alert-cht?token=<api_key>
#
# Author:
#   Neson

querystring = require('querystring')
url = require('url')

module.exports = (robot) ->
  robot.router.post "/hubot/newrelic-alert-cht", (req, res) ->
    query = querystring.parse(url.parse(req.url).query)

    if query.token == process.env["HUBOT_NEWRELIC_ALERT_CHT_API_KEY"]
      data = req.body
      for k of data
        eventString = data[k]
        eventType = k
        eventObj = JSON.parse(eventString)
        appName = eventObj?['application_name']?.replace(/[^a-zA-Z0-9]/g, '_')
        roomNames = (robot.brain.get("hubot-newrelic-alert-cht-rooms-#{appName}") || process.env["HUBOT_NEWRELIC_ALERT_CHT_DEFAULT_ROOM"]).split(',')

        for roomName in roomNames
          fullRoomName = (roomName + process.env["HUBOT_NEWRELIC_ALERT_CHT_ROOM_POSTFIX"])

          robot.messageRoom fullRoomName, eventString if process.env["HUBOT_NEWRELIC_ALERT_CHT_DEBUG"]

          switch eventType
            when 'alert'

              messageMatch = eventObj['message']?.match /unable to ping (.*)/
              if messageMatch
                if eventObj['short_description']?.match /All alerts have been closed/
                  message = "現在網站一切正常。 :smile:"
                else if eventObj['short_description']?.match /recovered|closed/
                  message = "恭喜，#{eventObj['application_name']}，#{messageMatch[1]} 看起來是回復正常了。 :sweat_smile:"
                else
                  message = "警報，倒站：#{eventObj['application_name']}，#{messageMatch[1]} 似乎掛了！ :skull:"
                robot.messageRoom fullRoomName, message

              messageMatch = eventObj['message']?.match /Server Not Reporting/
              if messageMatch
                if eventObj['short_description']?.match /All alerts have been closed/
                  message = "現在伺服器一切正常。 :smile:"
                else if eventObj['short_description']?.match /recovered|closed/
                  message = "恭喜，伺服器節點 #{eventObj['servers']?.join('、')} 似乎復活了。 :sweat_smile:"
                else
                  message = "注意，當機？伺服器節點 #{eventObj['servers']?.join('、')} 好像死掉了。 :sleeping:"
                robot.messageRoom fullRoomName, message

      res.end "{ success: 200 }"

    else
      res.end "{ error: 403 }"

  robot.respond /newrelic-alert-cht (.+) to (.+)/i, (msg) ->
    appName = msg.match[1].replace(/[^a-zA-Z0-9]/g, '_')
    robot.brain.set "hubot-newrelic-alert-cht-rooms-#{appName}", msg.match[2]
    robot.brain.save()

    msg.send("好，我會將關於 #{msg.match[1]} 的警報發送到 #{robot.brain.get("hubot-newrelic-alert-cht-rooms-#{appName}").split(',').join('、')}。")
