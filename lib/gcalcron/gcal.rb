class GCalCron
  class GCal
    def initialize mail,pass,feed
      @service = GoogleCalendar::Service.new mail,pass
      @cal = GoogleCalendar::Calendar::new @service,feed
    end
  end
end
