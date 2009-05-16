$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"

require 'test/unit'
require 'gcalcron'

class GCalCronTest < Test::Unit::TestCase
  def test_load
    assert GCalCron
    assert GCalCron::Cron
    assert GCalCron::GCal
  end
end
