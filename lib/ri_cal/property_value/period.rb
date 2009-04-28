module RiCal
  class PropertyValue
    # RiCal::PropertyValue::CalAddress represents an icalendar Period property value
    # which is defined in 
    # rfc 2445 section 4.3.9 p 39
    #
    # Known bugs.  This doesn't properly work when dtstart, dtend or duration are changed independently
    class Period < PropertyValue

      # The DATE-TIME on which the period starts
      attr_accessor :dtstart
      # The DATE-TIME on which the period ends
      attr_accessor :dtend
      # The DURATION of the period
      attr_accessor :duration

      def value=(string) # :nodoc:
        starter, terminator = *string.split("/")
        self.dtstart = PropertyValue::DateTime.new(self, :value => starter)
        if /P/ =~ terminator
          self.duration = PropertyValue::Duration.new(self, :value => terminator)
          self.dtend = dtstart + duration
        else
          self.dtend   = PropertyValue::DateTime.new(self, :value => terminator)
          self.duration = PropertyValue::Duration.from_datetimes(self, dtstart.to_datetime, dtend.to_datetime)        
        end
      end
      
      def for_parent(parent)
        if parent_component.nil
          @parent_component = parent
        elsif parent_component == parent
          self
        else
          Period.new(parent, :value => value)
        end
      end
      
      def self.convert(parent, ruby_object) # :nodoc:
        ruby_object.to_ri_cal_period_value.for_parent(parent)
      end

      # return the receiver
      def to_ri_cal_period_value
        self
      end

      # TODO: consider if this should be a period rather than a hash
      def occurrence_hash(default_duration) #:nodoc:
        {:start => self, :end => (default_duration ? self + default_duration : nil)}
      end

      def add_date_times_to(required_timezones) #:nodoc:
        dtstart.add_date_times_to(required_timezones)
        dtend.add_date_times_to(required_timezones)
      end
    end
  end
end