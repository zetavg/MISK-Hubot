# Description:
#   Notifies about Codeship shipping status via webhook
#
# Dependencies:
#   querystring
#   url
#
# Configuration:
#   HUBOT_CODESHIP_SHIP_WEBHOOK_KEY - API key in URL while calling this webhook
#   HUBOT_ROOMNAME_PREFIX
#   HUBOT_ROOMNAME_POSTFIX
#
# URLS:
#   POST /hubot/codeship-shipping?token=<api_key>&rooms=<room1,room2>&branches=<branch1,branch2>
#
# Author:
#   Neson

querystring = require('querystring')
url = require('url')

module.exports = (robot) ->
  # Route the request
  robot.router.post "/hubot/codeship-shipping", (req, res) ->
    query = querystring.parse(url.parse(req.url).query)

    # Check the token
    if query.token == process.env.HUBOT_CODESHIP_SHIP_WEBHOOK_KEY
      data = req.body

      # Parse each thing in the request
      for k of data
        thingType = k
        if typeof data[k] == 'object'
          thingObj = data[k]
        else if typeof data[k] == 'string'
          thingString = data[k]
          thingObj = JSON.parse(thingString)

        # Prepare variables
        roomNames = query.rooms?.split(',')
        roomNamePrefix = process.env.HUBOT_ROOMNAME_PREFIX || ''
        roomNamePostfix = process.env.HUBOT_ROOMNAME_POSTFIX || ''

        validBranches = query.branches?.split(',')

        { build_url, commit_url, status, project_full_name, commit_id, short_commit_id, message, committer, branch, project_id, build_id } = thingObj

        message = message.substring(0, 100) + '...' if message.length > 100

        # Check if posting is needed
        if validBranches.indexOf(branch) > -1

          # Post message in rooms
          for roomName in roomNames
            fullRoomName = (roomNamePrefix + roomName + roomNamePostfix)

            message = """
                      :ship: Codeship [#{status}]: #{project_full_name} (#{branch}) [#{short_commit_id}] - "#{message}"
                      by #{committer}
                      #{build_url}
                      """

            robot.messageRoom fullRoomName, message

      res.end "{ success: 200 }"

    else
      res.end "{ error: 403 }"
