# Description:
#   ASCII art
#
# Dependencies:
#   asciimo
#
# Configuration:
#   None
#
# Commands:
#   hubot ascii me <text> - Show text in ascii art
#   hubot ascii me with <font> <text> - Show text in ascii art with a specific font
#   hubot ascii fonts - Show available ascii font list
#
# Author:
#   atmos

asciimo = require('asciimo').Figlet

module.exports = (robot) ->
  robot.respond /ascii(?: me)?(?: with ([^ ]+))? (.+)/i, (msg) ->
    if msg.match[2] == 'fonts'
      return
    try
      text = msg.match[2]
      font = if msg.match[1] isnt undefined then msg.match[1] else 'Doom'
      r = 1
      asciimo.write text, font, (art) ->
        msg.send "```\n#{art}\n```" if r
        r = 0
    catch e
      return

  robot.respond /ascii fonts/i, (msg) ->
    msg.send "Available fonts:\n3-d Epic Pawp 3x5 Fender Peaks cosmic 5lineoblique Fraktur Pebbles dotmatrix Acrobatic Fuzzy Pepper drpepper Alligator Goofy Poison eftichess Alligator2 Gothic Puffy Alphabet Graceful Pyramid eftifont Avatar Gradient Rectangles eftipiti Banner Graffiti Relief eftirobot Banner3 Hex Relief2 eftitalic Banner4 Hollywood Roman Barbwire Invita Rot13 eftiwall Basic Isometric1 Rounded Bell Isometric2 Rozzo eftiwater Binary Isometric3 Runyc fourtops Broadway Isometric4 Serifcap l4me Bulbhead Italic Short larry3d Jazmine Slide Caligraphy Katakana Speed nancyj-fancy Catwalk Kban Stacey nancyj-underlined Chunky LCD Stampatello Coinstak Letters Stellar nvscript Colossal Linux Stop rev Computer Lockergnome Straight Contessa Madrid Tanja rowancap Contrast Marquee Thick sblood Cosmike Maxfour Thin slscript Crawford Mike Ticks smisome1 Cricket Mirror Tombstone smkeyboard Cyberlarge Nancyj Trek starwars Cybermedium Nipples Tsalagi Cybersmall O8 Univers threepoint DWhistled OS2 Weird ticksslant Decimal Whimsy tinker-toy Diamond banner3-D Doh twopoint Doom Octal bigchief usaflag Double Ogre calgphy2"
