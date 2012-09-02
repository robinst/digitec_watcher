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
      doc = Nokogiri::HTML(open(url).read, nil, 'utf-8')
      price = doc.css('td.preis').text
      article = doc.css('#PanelKopf h4').text
      delivery_table = doc.css('#p table tr').first
      delivery_table.css("br").each do |br|
        br.replace(" ")
      end
      delivery = delivery_table.text.strip
      { :article_title => article, :price => price, :delivery => delivery }
    end
  end

  class Checker
    def initialize(config, changes_file, parser=NokogiriParser.new)
      @config = config
      @changes_file = changes_file
      @parser = parser
      if File.exists?(changes_file)
        changes_data = File.open(changes_file) { |f| f.read }
        changes = JSON.parse(changes_data)
        @changes = migrate_old_changes(changes)
      else
        @changes = {}
      end
    end

    def check
      notifications = []
      urls = @config.watches.map{ |watch| watch.urls }.flatten.uniq
      urls.each do |url|
        result = @parser.parse(url)
        price = result[:price]
        delivery = result[:delivery]
        article_title = result[:article_title]
        changes = @changes[url] || []
        last_price = (changes.last || {})['price']
        last_delivery = (changes.last || {})['delivery']
        if changes.empty? || last_price != price || last_delivery != delivery
          changes << { 'price' => price, 'delivery' => delivery }

          affected_watches = @config.watches.select{ |watch| watch.urls.include?(url) }
          recipients = affected_watches.map{ |watch| watch.recipients }.flatten
          notification = Notification.new
          notification.recipients = recipients
          notification.url = url
          notification.article_title = article_title
          notification.price = price
          notification.last_price = last_price
          notification.delivery = delivery
          notification.last_delivery = last_delivery
          notifications << notification
        end
        @changes[url] = changes
      end
      notifications
    end

    def save_changes
      File.open(@changes_file, 'w') do |f|
        f.write(JSON.generate(@changes))
      end
    end

    private

    def migrate_old_changes(changes)
      migrated = {}
      changes.each do |url, value|
        new_value = value.map{ |v|
          if v.is_a?(String)
            { 'price' => v }
          else
            v
          end
        }
        migrated[url] = new_value
      end
      migrated
    end
  end

  class Notification
    attr_accessor :recipients, :url, :article_title, :price, :last_price, :delivery, :last_delivery
  end

  class Notifier
    def self.send_notifications(notifications)
      notifications.each do |n|
        puts "Notifying #{n.recipients} about #{n.url}: " + n.inspect
        mail = Mailer.change_email(n)
        mail.deliver
      end
    end
  end
end
