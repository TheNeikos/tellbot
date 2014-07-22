#A tellbot built for the #slash channel on the ghb network

require 'cinch'


messages = {}

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.ghb.hs-furtwangen.de"
    c.channels = ["#testing"]
    c.nick = "TellBot"
  end

  on :message, /^!tell (.+?) (.+)/ do |m, nick, msg|
    next unless bot.channels[0].users.keys.select {|u| u.nick == nick}.empty?
    m.action_reply "will tell %s once they come online" % [Format(:bold, :blue, nick)]
    nick.split(',').each do |n|
      puts n
      messages[n] ||= []
      messages[n].push({msg: msg, author: m.user.nick})
    end
  end

  on :join do |m|
    debug m.user.nick
    debug messages[m.user.nick].inspect
    if (messages[m.user.nick] ||= []).size > 0
      messages[m.user.nick].each do |msg|
        m.reply "You have been told %s by %s while you were away" % [Format(:bold, msg[:msg]),
                                                                     Format(:bold, :blue, msg[:author])]
      end
      messages[m.user.nick] = []
    end
  end
end

bot.start

