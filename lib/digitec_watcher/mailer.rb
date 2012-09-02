require 'action_mailer'

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :sendmail
ActionMailer::Base.view_paths = File.join(File.dirname(__FILE__), '..')

module DigitecWatcher
  class Mailer < ActionMailer::Base
    def change_email(notification)
      @url = notification.url
      @price = notification.price
      @last_price = notification.last_price
      @delivery = notification.delivery
      @last_delivery = notification.last_delivery
      article = notification.article_title
      mail(:to => notification.recipients,
           :from => "Digitec Watcher <noreply@nibor.org>",
           :subject => "#{article}") do |format|
        format.text
      end
    end
  end
end
