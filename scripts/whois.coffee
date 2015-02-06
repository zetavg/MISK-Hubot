# Description:
#   looks up the whois information for a domain
# Dependencies:
#   None
# Configuration:
#   None
# Commands:
#   hubot whois domain - looks up the whois information for a given domain
# Author:
#   dryan

firstof = (args) ->
  output = null
  for arg in args
    if typeof arg != "undefined"
      output = arg
      break
  output

module.exports = (robot) ->
  robot.respond /.*whois ([^.]+\.[^\s]*).*/i, (msg) ->
    domain = msg.match[1].trim()
    err_message = "Sorry, there was an error looking up #{domain}."
    msg.http("http://www.whoisxmlapi.com/whoisserver/WhoisService?outputFormat=json&domainName=#{domain}").get() (err, res, body) ->
      if err
        msg.send err_message
      response = JSON.parse(body)
      if response and response.WhoisRecord
        domain = response.WhoisRecord.domainName
        registrant = firstof([response.WhoisRecord.registrant, response.WhoisRecord.registryData.registrant])
        administrativeContact = firstof([response.WhoisRecord.administrativeContact, response.WhoisRecord.registryData.administrativeContact])
        technicalContact = firstof([response.WhoisRecord.technicalContact, response.WhoisRecord.registryData.technicalContact])
        nameServers = firstof([response.WhoisRecord.nameServers, response.WhoisRecord.registryData.nameServers])
        createdDate = firstof([response.WhoisRecord.createdDate, response.WhoisRecord.registryData.createdDate, "unknown"]).replace(/[\.,-\/#!$%\^&\*;:{}=\-_`~()]+$/, '')
        updatedDate = firstof([response.WhoisRecord.updatedDate, response.WhoisRecord.registryData.updatedDate, "unknown"]).replace(/[\.,-\/#!$%\^&\*;:{}=\-_`~()]+$/, '')
        expiresDate = firstof([response.WhoisRecord.expiresDate, response.WhoisRecord.registryData.expiresDate, "unknown"]).replace(/[\.,-\/#!$%\^&\*;:{}=\-_`~()]+$/, '')
        registrarName = firstof([response.WhoisRecord.registrarName, response.WhoisRecord.registryData.registrarName, "unknown"]).replace(/[\.,-\/#!$%\^&\*;:{}=\-_`~()]+$/, '')

        output = [
          "Whois for #{domain}"
          ""
          "Created: #{createdDate}"
          "Updated: #{updatedDate}"
          "Expires: #{expiresDate}"
          "Registrar: #{registrarName}"
        ]

        sections = "Registrant": registrant, "Administrative Contact": administrativeContact, "Technical Contact": technicalContact

        for key, data of sections
          if data
            output.push ""
            output.push "#{key}"
            output.push "======================"
            output.push "#{firstof([data.organization, data.unparsable])}"
            if data.street1
              output.push "#{data.street1}"
            output.push "#{data.city}, #{data.state} #{data.postalCode}"
            if data.email
              output.push data.email
        if nameServers
          output.push ""
          output.push "Nameservers"
          output.push "======================"
          output.push hostName for hostName in nameServers.hostNames
        msg.send output.join "\n"
      else
        msg.send err_message
