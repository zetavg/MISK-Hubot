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

      switch data.event
        when 'Setup'
          message = """
                    :rocket: Server #{data.hostname} has been setup.
                    ```
                    id: #{data.id}, type: #{data.instance_type}, ip: #{data.ip}, private_ip: #{data.private_ip}, layers: #{data.layers}, backends: #{data.backends}, aws_instance_id:#{data.aws_instance_id}
                    ```
                    """
        when 'Shutdown'
          message = """
                    :zzz: Server #{data.hostname} is shutting down.
                    ```
                    id: #{data.id}, type: #{data.instance_type}, ip: #{data.ip}, private_ip: #{data.private_ip}, layers: #{data.layers}, backends: #{data.backends}, aws_instance_id:#{data.aws_instance_id}
                    ```
                    """
        when 'Deploy'
          message = """
                    :white_check_mark: Application #{data.application} has been successfully deployed to #{data.hostname}.
                    ```
                    Application Deploy - domains: #{data.deploy.domains}, by: #{data.deploy.deploying_user}, application_type: #{data.deploy.application_type}
                    Server - id: #{data.id}, type: #{data.instance_type}, ip: #{data.ip}, private_ip: #{data.private_ip}, layers: #{data.layers}, backends: #{data.backends}, aws_instance_id:#{data.aws_instance_id}
                    ```
                    """
        when 'Undeploy'
          message = """
                    :wine_glass: Application #{data.application} has been undeployed from #{data.hostname}.
                    ```
                    Application Deploy - domains: #{data.deploy.domains}, by: #{data.deploy.deploying_user}, application_type: #{data.deploy.application_type}
                    Server - id: #{data.id}, type: #{data.instance_type}, ip: #{data.ip}, private_ip: #{data.private_ip}, layers: #{data.layers}, backends: #{data.backends}, aws_instance_id:#{data.aws_instance_id}
                    ```
                    """
        else
          message = """
                    Server #{data.hostname}: #{data.event}
                    ```
                    #{JSON.stringify(data)}
                    ```
                    """

      # Post message in rooms
      for roomName in roomNames
        fullRoomName = (roomNamePrefix + roomName + roomNamePostfix)
        robot.messageRoom fullRoomName, message

      res.end "{ success: 200 }"

    else
      res.end "{ error: 403 }"
