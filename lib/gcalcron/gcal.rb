class GCalCron
  class GCal
    def initialize mail,pass,feed
      @service = GoogleCalendar::Service.new mail,pass
      @cal = GoogleCalendar::Calendar::new @service,feed
      @raw = @service.query feed
      raise InvalidCalendarURL unless @raw.code == "200"
      @list = events
      @offset = DateTime.parse(Time.new.to_s).offset
    end
    attr_reader :list,:offset

    private

    def events
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
        "recurrence" => { "element" => "gd:recurrence", "to_xml" => "rec_instance_to_str", "from_xml" => "str_to_rec_instance"}
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

      def str_to_rec_instance str
        self.recurrence = Recurrence.new str,@offset
        #self.st = self.recurrence.dtstart if self.st.nil? and !self.recurrence.dtstart.nil? 
        #self.en = self.recurrence.dtend if !self.en.nil? and !self.recurrence.dtend.nil?
      end

      def rec_instance_to_str rec
        self.recurrence.raw
      end

      class Recurrence

        DT_RULE = /(\w+);TZID=(.+):(.+)/
        RRULE_RULE = /(\w+)=(\w+)/
        BLOCK_RULE = /(BEGIN|END):(\w+)/
        ELEM_RULE = /(.+):(.+)/

        def initialize str,offset
          @raw = str
          @offset = offset
          set_instance_vals
        end

        private

        def set_instance_vals
          hash = parse_recurrence
          hash.each do |key,value|
            self.instance_eval %{
              def #{key}
                @#{key}
              end

              def #{key}= (value)
                @#{key} = value
              end
            }
            self.send("#{key}=",value)
          end
        end

        def parse_recurrence
          rec = @raw.split "\n"
          ret = {}
          block_names = []
          blocks = {}
          rec.each do |e|
            if e.match(DT_RULE)
              dt = e.match(DT_RULE).to_a
              time = Time.parse(dt[3]).getutc
              ret[dt[1].downcase] = time
              ret["tzid"] = dt[2] if ret["tzid"].nil?
            elsif e.match(RRULE_RULE)
              rrules = e.scan(RRULE_RULE)
              ret["rrule"] = {} if ret["rrule"].nil?
              rrules.each do |rrule|
                ret["rrule"][rrule[0].downcase] = rrule[1]
              end
            elsif e.match(BLOCK_RULE)
              block = e.match(BLOCK_RULE).to_a
              if block[1] == "BEGIN"
                block_names.push block[2].downcase
                blocks[block_names.last] = {}
              elsif block[1] == "END"
                del = block_names.pop
                unless block_names.empty?
                  blocks[block_names.last][del] = blocks[del]
                else
                  ret[del] = blocks[del]
                end
              end
            else
              elems = e.match(ELEM_RULE).to_a
              unless block_names.empty?
                blocks[block_names.last][elems[1].downcase] = elems[2]
              else
                ret[elems[1].downcase] = elems[2]
              end
            end
          end
          ret
        end
      end
    end
  end
end
