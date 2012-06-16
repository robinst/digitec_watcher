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

  class NokogiriParser
    def parse(url)
      doc = Nokogiri::HTML(open(url))
      price = doc.css('td.preis').text
      article = doc.css('#PanelKopf h4').text
      { :price => price, :article_title => article }
    end
  end

  class Checker
    def initialize(config, changes_file, parser=NokogiriParser.new)
      @config = config
      @changes_file = changes_file
      @parser = parser
      if File.exists?(changes_file)
        changes_data = File.open(changes_file) { |f| f.read }
        @changes = JSON.parse(changes_data)
      else
        @changes = {}
      end
    end

    def check
      notifications = []
      @config.watches.each do |watch|
        watch.urls.each do |url|
          result = @parser.parse(url)
          price = result[:price]
          article_title = result[:article_title]
          changes = @changes[url] || []
          if changes.empty? || changes.last != price
            last_price = changes.last || ""
            notification = Notification.new
            notification.recipients = watch.recipients
            notification.url = url
            notification.article_title = article_title
            notification.price = price
            notification.last_price = last_price
            notifications << notification
            changes << price
          end
          @changes[url] = changes
        end
      end
      notifications
    end

    def save_changes
      File.open(@changes_file, 'w') do |f|
        f.write(JSON.generate(@changes))
      end
    end
  end

  class Notification
    attr_accessor :recipients, :url, :article_title, :price, :last_price
  end

  class Notifier
    def self.send_notifications(notifications)
      notifications.each do |n|
        puts "Notifying #{n.recipients} about #{n.url} " +
             "changing from #{n.last_price} to #{n.price}"
        mail = Mailer.change_email(n)
        mail.deliver
      end
    end
  end
end
