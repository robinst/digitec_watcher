# For running directly without having to install gem
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'digitec_watcher'

config = DigitecWatcher::Config.from_json("config.json")
checker = DigitecWatcher::Checker.new(config, "changes.json")
notifications = checker.check
DigitecWatcher::Notifier.send_notifications(notifications)
checker.save_changes
