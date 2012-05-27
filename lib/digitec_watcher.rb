require 'digitec_watcher/version'
require 'digitec_watcher/mailer'

require 'json'
require 'open-uri'
require 'nokogiri'

module DigitecWatcher
  class Config
    attr_reader :watches

    def self.from_json(config_file)
      config_data = File.open(config_file) { |f| f.read }
      config = JSON.parse(config_data)
      watches_config = config['watches']
      watches = watches_config.map{ |w| Watch.new(w['urls'], w['recipients']) }
      Config.new(watches)
    end

    def initialize(watches)
      @watches = watches
    end
  end

  class Watch
    attr_reader :urls, :recipients

    def initialize(urls, recipients)
      @urls = urls
      @recipients = recipients
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
        watch.urls.each do |url|
          doc = Nokogiri::HTML(open(url))
          price = doc.css('td.preis').text
          article = doc.css('#PanelKopf h4').text
          changes = @changes[url] || []
          if changes.empty? || changes.last != price
            last_price = changes.last || ""
            notify(watch.recipients, url, article, price, last_price)
            changes << price
          end
          @changes[url] = changes
        end
      end
    end

    def save_changes
      File.open(@changes_file, 'w') do |f|
        f.write(JSON.generate(@changes))
      end
    end

    private

    def notify(recipients, url, article, price, last_price)
      puts "Notifying #{recipients} about #{url} " +
           "changing from #{last_price} to #{price}"
      mail = Mailer.change_email(recipients, url, article, price, last_price)
      mail.deliver
    end
  end
end
