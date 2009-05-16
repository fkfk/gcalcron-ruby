$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"

require 'test/unit'
require 'gcalcron'
require 'pit'

class GCalCronTest < Test::Unit::TestCase
  def test_load
    assert GCalCron
    assert GCalCron::Cron
    assert GCalCron::GCal
  end

  def test_new
    conf = Pit.get("gcalcron")
    gcalcron = GCalCron.new conf["mail"],conf["pass"],conf["feed"]
    assert gcalcron
    assert gcalcron.cron
    assert gcalcron.cal
  end

  def test_gcal_access
    conf = Pit.get("gcalcron")
    gcalcron = GCalCron.new conf["mail"],conf["pass"],conf["feed"]
    assert gcalcron.cal.events.class == Array
  end
end
