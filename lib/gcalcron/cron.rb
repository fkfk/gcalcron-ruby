class GCalCron
  class Cron
    def initialize user=nil
      @crontab = CronEdit::Crontab.new user
      @list = @crontab.list.map {|k,v| v}
    end
    attr_reader :list
  end
end
