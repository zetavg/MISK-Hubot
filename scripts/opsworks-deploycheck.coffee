# Description:
#   Notifies about Codeship shipping status via webhook
#
# Dependencies:
#   querystring
#   url
#   aws-sdk
#
# Configuration:
#   HUBOT_OPSWORKS_DEPLOYCHECK_WEBHOOK_KEY - API key in URL while calling this webhook
#   HUBOT_ROOMNAME_PREFIX
#   HUBOT_ROOMNAME_POSTFIX
#   HUBOT_AWS_ACCESS_KEY_ID
#   HUBOT_AWS_SECRET_ACCESS_KEY
#
# URLS:
#   POST /hubot/opsworks-deploycheck?token=<api_key>&rooms=<room1,room2>
#
# Author:
#   Neson

querystring = require('querystring')
url = require('url')
AWS = require('aws-sdk')

module.exports = (robot) ->
  # Route the request
  robot.router.post "/hubot/opsworks-deploycheck", (req, res) ->
    query = querystring.parse(url.parse(req.url).query)

    # Check the token
    if query.token == process.env.HUBOT_OPSWORKS_DEPLOYCHECK_WEBHOOK_KEY

      AWS.config.update
        accessKeyId: process.env.HUBOT_AWS_ACCESS_KEY_ID
        secretAccessKey: process.env.HUBOT_AWS_SECRET_ACCESS_KEY
        region: 'us-east-1'
      opsworks = new AWS.OpsWorks

      data = req.body

      # Prepare variables
      roomNames = query.rooms?.split(',')
      roomNamePrefix = process.env.HUBOT_ROOMNAME_PREFIX || ''
      roomNamePostfix = process.env.HUBOT_ROOMNAME_POSTFIX || ''

      deploymentId = data.DeploymentId

      checkStatus = (deploymentId) ->

        opsworks.describeDeployments { DeploymentIds: [ deploymentId ] }, (err, data) ->
          if err
            console.error err, err.stack
          else
            deployment = data['Deployments'][0]
            if deployment['Status'] == 'running' || !deployment['Duration']
              setTimeout( ->
                checkStatus(deploymentId)
              , 10000)
            else
              opsworks.describeApps { AppIds: [ deployment['AppId'] ] }, (err, data) ->
                app = data['Apps'][0]
                if deployment['Status'] == 'successful'
                  message = """
                            :o: #{app['Name']} (#{app['Shortname']}) (#{app['Type']}) has been successfully deployed on OpsWorks in #{deployment['Duration']} seconds.
                            ```
                            app_id: #{deployment['AppId']}, deployment_id: #{deployment['DeploymentId']}, stack_id: #{deployment['StackId']}
                            instance_ids: #{deployment['InstanceIds']}
                            https://console.aws.amazon.com/opsworks/home#/stack/#{deployment['StackId']}/deployments/#{deployment['DeploymentId']}
                            ```
                            """
                else
                  message = """
                            :x: #{app['Name']} (#{app['Shortname']}) (#{app['Type']}) has #{deployment['Status']} to deploy on OpsWorks in #{deployment['Duration']} seconds.
                            ```
                            app_id: #{deployment['AppId']}, deployment_id: #{deployment['DeploymentId']}, stack_id: #{deployment['StackId']}
                            instance_ids: #{deployment['InstanceIds']}
                            https://console.aws.amazon.com/opsworks/home#/stack/#{deployment['StackId']}/deployments/#{deployment['DeploymentId']}
                            ```
                            """

                # Post message in rooms
                for roomName in roomNames
                  fullRoomName = (roomNamePrefix + roomName + roomNamePostfix)
                  robot.messageRoom(fullRoomName, message) if message

      checkStatus(deploymentId)

      res.end "{ success: 200 }"

    else
      res.end "{ error: 403 }"
