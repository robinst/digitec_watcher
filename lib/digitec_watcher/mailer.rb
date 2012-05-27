require 'action_mailer'

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :sendmail
ActionMailer::Base.view_paths = File.join(File.dirname(__FILE__), '..')

module DigitecWatcher
  class Mailer < ActionMailer::Base
    def change_email(recipients, url, article, price, last_price)
      @url = url
      @price = price
      @last_price = last_price
      mail(:to => recipients,
           :from => "Digitec Watcher <noreply@nibor.org>",
           :subject => "Price changed for #{article}") do |format|
        format.text
      end
    end
  end
end
