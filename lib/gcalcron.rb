require "rubygems"
require "cronedit"
require "gcalapi"
require "time"
require "date"
require "gcalcron/cron"
require "gcalcron/gcal"

class GCalCron
  def initialize mail,pass,feed,user=nil
    @cron = Cron.new user
    @cal = GCal.new mail,pass,feed
  end
  attr_reader :cal,:cron
end
