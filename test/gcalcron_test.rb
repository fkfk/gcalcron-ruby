$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"

require 'test/unit'
require 'gcalcron'
require 'pit'

def new_instance
  conf = Pit.get("gcalcron")
  GCalCron.new conf["mail"],conf["pass"],conf["feed"]
end

class GCalCronTest < Test::Unit::TestCase
  def test_load
    assert GCalCron
    assert GCalCron::Cron
    assert GCalCron::GCal
  end

  def test_new
    gcalcron = new_instance
    assert gcalcron
    assert gcalcron.cron
    assert gcalcron.cal
  end

  def test_gcal_access
    gcalcron = new_instance
    assert gcalcron.cal.events.class == Array
  end

  def test_cron_access
    gcalcron = new_instance
    assert gcalcron.cron.list.class == Array
  end
end
