# Digitec Watcher

Script to watch the Digitec website for price or delivery status changes
and send out notifications per e-mail.

## Usage

The script uses Ruby and Bundler for installing dependencies. To make sure
bundler is installed, run `gem install bundler`. Then:

1. Clone this repo
2. Run `bundle install` inside the cloned repository
3. Copy the config.sample.json to config.json and change URLs and e-mail
4. Run notify.rb as a cron job at desired interval

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
