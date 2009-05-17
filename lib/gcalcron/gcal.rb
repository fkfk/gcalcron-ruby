class GCalCron
  class GCal
    def initialize mail,pass,feed
      @service = GoogleCalendar::Service.new mail,pass
      @cal = GoogleCalendar::Calendar::new @service,feed
      @raw = @service.query feed
      raise InvalidCalendarURL unless @raw.code == "200"
      @events = get_events
    end
    attr_reader :events

    end

    private

    def get_events
      REXML::Document.new(@raw.body).root.elements.each("entry"){}.map do |elem|
        elem.attributes["xmlns:gCal"] = "http://schemas.google.com/gCal/2005"
        elem.attributes["xmlns:gd"] = "http://schemas.google.com/g/2005"
        elem.attributes["xmlns"] = "http://www.w3.org/2005/Atom"
        entry = Event.new
        entry.srv = @srv
        entry.load_xml("<?xml version='1.0' encoding='UTF-8'?>#{elem.to_s}")
      end
    end

    class Event < GoogleCalendar::Event
      ATTRIBUTES_TEMP = {
        "title" => { "element" => "title"},
        "desc" => { "element" => "content"},
        "where" => { "element" => "gd:where", "attribute" => "valueString" },
        "st" => { "element" => "gd:when", "attribute" => "startTime", "to_xml" => "time_to_str", "from_xml" => "str_to_time" },
        "en" => { "element" => "gd:when", "attribute" => "endTime", "to_xml" => "time_to_str", "from_xml" => "str_to_time" },
        "recurrence" => { "element" => "gd:recurrence"}
      }
      attr_accessor :allday, :feed, :srv, :status, :where, :title, :desc, :st, :en, :xml, :recurrence

      def xml_to_instance
        ATTRIBUTES_TEMP.each do |name, hash|
          elem = @xml.root.elements[hash["element"]]
          unless elem.nil?
            val = (hash.has_key?("attribute") ? elem.attributes[hash["attribute"]] : elem.text)
            val = self.send(hash["from_xml"], val) if hash.has_key?("from_xml")
            self.send(name+"=", val)
          end
        end
        self.status = :old

        @xml.root.elements.each("link") do |link|
          @feed = link.attributes["href"] if link.attributes["rel"] == "edit"
        end
      end

      def instance_to_xml
        ATTRIBUTES_TEMP.each do |name, hash|
          elem = @xml.root.elements[hash["element"]]
          elem = @xml.root.elements.add(hash["element"]) if elem.nil?
          val = self.send(name)
          val = self.send(hash["to_xml"], val) if hash.has_key?("to_xml")
          if hash.has_key?("attribute")
            elem.attributes[hash["attribute"]] = val
          else
            elem.text = val
          end
        end
      end
    end
  end
end
