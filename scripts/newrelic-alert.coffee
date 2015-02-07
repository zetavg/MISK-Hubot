# Description:
#   Notifies about New Relic events via webhook
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_NEWRELIC_ALERT_API_KEY - API key in URL while calling this webhook
#   HUBOT_NEWRELIC_ALERT_DEFAULT_ROOM - The default room to which message should go
#   HUBOT_NEWRELIC_ALERT_ROOM_POSTFIX
#   HUBOT_NEWRELIC_ALERT_DEBUG
#
# Commands:
#   hubot newrelic-alert <application_name> to <room_names (split with ',')> - Sets where an app's alert should goes to
#
# URLS:
#   POST /hubot/newrelic-alert?token=<api_key>
#
# Author:
#   Neson

querystring = require('querystring')
url = require('url')

module.exports = (robot) ->
  robot.router.post "/hubot/newrelic-alert", (req, res) ->
    query = querystring.parse(url.parse(req.url).query)

    if query.token == process.env["HUBOT_NEWRELIC_ALERT_API_KEY"]
      data = req.body
      for k of data
        eventString = data[k]
        eventType = k
        eventObj = JSON.parse(eventString)
        appName = eventObj?['application_name']?.replace(/[^a-zA-Z0-9]/g, '_')
        roomNames = (robot.brain.get("hubot-newrelic-alert-rooms-#{appName}") || process.env["HUBOT_NEWRELIC_ALERT_DEFAULT_ROOM"]).split(',')

        for roomName in roomNames
          fullRoomName = (roomName + process.env["HUBOT_NEWRELIC_ALERT_ROOM_POSTFIX"])

          robot.messageRoom fullRoomName, eventString if process.env["HUBOT_NEWRELIC_ALERT_DEBUG"]

          switch eventType
            when 'alert'
              message = "NewRelic [#{eventType}]: #{eventObj['long_description']} (#{eventObj['severity']}) (#{eventObj['account_name']})\r\n#{eventObj['alert_url']}"
              robot.messageRoom fullRoomName, message
            when 'deployment'
              message = "NewRelic [#{eventType}]: #{eventObj['deployed_by']} deployed #{appName}: #{eventObj['description']}\r\n#{eventObj['changelog']} (#{eventObj['revision']}) (#{eventObj['account_name']})\r\n#{eventObj['deployment_url']}"
              robot.messageRoom fullRoomName, message

      res.end "{ success: 200 }"

    else
      res.end "{ error: 403 }"

  robot.respond /newrelic-alert (.+) to (.+)/i, (msg) ->
    appName = msg.match[1].replace(/[^a-zA-Z0-9]/g, '_')
    robot.brain.set "hubot-newrelic-alert-rooms-#{appName}", msg.match[2]
    robot.brain.save()

    msg.send("Okay, I will send notifications about #{msg.match[1]} to #{robot.brain.get("hubot-newrelic-alert-rooms-#{appName}").split(',').join(', ')}.")
