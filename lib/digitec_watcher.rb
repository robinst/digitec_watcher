require 'digitec_watcher/version'
require 'digitec_watcher/mailer'

require 'json'
require 'open-uri'
require 'nokogiri'

module DigitecWatcher
  class Config
    attr_reader :recipients, :watches

    def self.from_json(config_file)
      config_data = File.open(config_file) { |f| f.read }
      config = JSON.parse(config_data)
      recipients = config['recipients']
      watches = config['watches']
      Config.new(recipients, watches)
    end

    def initialize(recipients, watches)
      @recipients = recipients
      @watches = watches
    end
  end

  class Checker
    def initialize(config, changes_file)
      @config = config
      @changes_file = changes_file
      if File.exists?(changes_file)
        changes_data = File.open(changes_file) { |f| f.read }
        @changes = JSON.parse(changes_data)
      else
        @changes = {}
      end
    end

    def check_and_notify
      @config.watches.each do |watch|
        doc = Nokogiri::HTML(open(watch))
        price = doc.css('td.preis').text
        changes = @changes[watch] || []
        if changes.empty? || changes.last != price
          last_price = changes.last || ""
          notify(watch, price, last_price)
          changes << price
        end
        @changes[watch] = changes
      end
    end

    def save_changes
      File.open(@changes_file, 'w') do |f|
        f.write(JSON.generate(@changes))
      end
    end

    private

    def notify(watch, price, last_price)
      puts "Notifying #{@config.recipients} about #{watch} " +
           "changing from #{last_price} to #{price}"
      mail = Mailer.change_email(@config.recipients, watch, price, last_price)
      mail.deliver
    end
  end
end
