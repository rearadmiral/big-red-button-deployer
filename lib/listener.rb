require_relative 'button_handler'

class Listener

  def initialize(config)
    @config = config
  end

  def start
    handler = ButtonHandler.new(@config)

    puts "fake button"

    handler.open
    # puts "finding button..."
    # DreamCheeky::BigRedButton.run do
    #
    #   puts "listening for events..."
    #
    #   open do
    #     puts "EVENT: lid opened"
    #     handler.open
    #   end
    #
    #   push do
    #     puts "EVENT: button pushed"
    #     handler.push
    #   end
    #
    #   close do
    #     puts "EVENT: lid closed"
    #     handler.close
    #   end
    #
    # end
  end


end
