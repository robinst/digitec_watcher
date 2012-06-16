require File.join(File.dirname(__FILE__), 'helper')

class CheckerTest < Test::Unit::TestCase
  class TestParser
    def initialize(results)
      @results = results
    end

    def parse(url)
      @results[url]
    end
  end

  context "DigitecWatcher::Checker" do
    setup do
      watch1 = DigitecWatcher::Watch.new(["url1", "url2"], ["recipient1", "recipient2"])
      watch2 = DigitecWatcher::Watch.new(["url1", "url3"], ["recipient3"])
      config = DigitecWatcher::Config.new([watch1, watch2])
      parser = TestParser.new({ "url1" => { :price => 1 }, "url2" => { :price => 2 }, "url3" => { :price => 3 } })
      @checker = DigitecWatcher::Checker.new(config, "changes_file", parser)
    end

    should "return notifications" do
      notifications = @checker.check
      assert !notifications.empty?
    end

    should "bundle notifications about the same URL" do
      notifications = @checker.check
      assert_equal 3, notifications.size
      assert_equal "url1", notifications[0].url
      assert_equal "url2", notifications[1].url
      assert_equal "url3", notifications[2].url

      assert_equal ["recipient1", "recipient2", "recipient3"], notifications[0].recipients
    end
  end
end
