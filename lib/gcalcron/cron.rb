class GCalCron
  class Cron
    def initialize user=nil
      @crontab = CronEdit::Crontab.new user
      @list = @crontab.list.map {|k,v| CronEdit::CronEntry.new(v).to_hash}
    end
    attr_reader :list
  end
end
