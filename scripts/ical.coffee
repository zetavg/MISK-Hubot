# Description:
#   Generates an ical event.
#
# Dependencies:
#   date-parser moment
#
# Commands:
#   hubot ical <事件日期時間> (https://github.com/Neson/date-parser)
#
# Author:
#   Neson

dateParser = require('date-parser')
moment = require('moment-timezone')

module.exports = (robot) ->
  robot.respond /(?:ical|ics) (.*)/i, (msg) ->
    date = dateParser.parse(msg.match[1])

    if date
      base_url = 'https://infinite-oasis-2444.herokuapp.com'
      request = ['/?']

      request.push "start_time=#{date.toISOString()}&"
      request.push "end_time=#{date.endTime?.toISOString()}&" if date.endTime
      request.push "title=#{date.eventName}&" if date.eventName
      request.push "location=#{date.location}&" if date.location
      request.push "full_day=true&" if date.fullDay

      url = base_url + request.join('')

      msg.send url
    else
      msg.send '聽不懂 XDrz'
