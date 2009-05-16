class GCalCron
  class Cron
    def initialize user=nil
      @crontab = CronEdit::Crontab.new user
    end
  end
end
