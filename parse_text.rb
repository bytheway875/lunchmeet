class ParseText
  require 'chronic'
  attr_reader :body
  attr_accessor :date, :event
  attr_accessor :readable_date
  def initialize(body)
    @body = body
    find_date
    find_event
  end

  def find_date
    @date = Chronic.parse(body).to_date
    @readable_date = readable_date
  end

  def find_event
    happy_hour = /(happy hour|happyhour|drinks|drink)/.match(body.downcase).to_a.first ? 'happy hour' : nil
    lunch = /(lunch|food|a meal)/.match(body).to_a.first ? 'lunch' : nil if @event.nil?
    @event = happy_hour || lunch
  end

  def readable_date
    case
    when date == Date.today
      "today"
    when date == Date.today + 1
      "tomorrow"
    else
      "on " + date.strftime("%m/%d/%Y")
    end
  end

  def response
    if event && readable_date
      "So you want to go to #{event} #{readable_date}?"
    else
      "Sorry I didn't catch that. Can you tell me again?"
    end
  end
end