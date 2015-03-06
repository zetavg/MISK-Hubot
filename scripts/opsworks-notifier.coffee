# Description:
#   Notifies about Codeship shipping status via webhook
#
# Dependencies:
#   querystring
#   url
#
# Configuration:
#   HUBOT_OPSWORKS_NOTIFIER_WEBHOOK_KEY - API key in URL while calling this webhook
#   HUBOT_ROOMNAME_PREFIX
#   HUBOT_ROOMNAME_POSTFIX
#
# URLS:
#   POST /hubot/opsworks-notifier?token=<api_key>&rooms=<room1,room2>
#
# Author:
#   Neson

querystring = require('querystring')
url = require('url')

module.exports = (robot) ->
  # Route the request
  robot.router.post "/hubot/opsworks-notifier", (req, res) ->
    query = querystring.parse(url.parse(req.url).query)

    # Check the token
    if query.token == process.env.HUBOT_OPSWORKS_NOTIFIER_WEBHOOK_KEY

      data = req.body
      if 'application' in data
        application = JSON.parse(data.application)
      else
        application = {}
      if 'deploy' in data
        deploy = JSON.parse(data.deploy)
      else
        deploy = {}

      # Prepare variables
      roomNames = query.rooms?.split(',')
      roomNamePrefix = process.env.HUBOT_ROOMNAME_PREFIX || ''
      roomNamePostfix = process.env.HUBOT_ROOMNAME_POSTFIX || ''

      # Post message in rooms
      for roomName in roomNames
        fullRoomName = (roomNamePrefix + roomName + roomNamePostfix)

        message = """
                  #{data.event}
                  ```
                  #{JSON.stringify(data)}
                  ```
                  """

        robot.messageRoom fullRoomName, message

      res.end "{ success: 200 }"

    else
      res.end "{ error: 403 }"
