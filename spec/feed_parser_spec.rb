require 'bamboozled/feed_parser'

describe Bamboozled::FeedParser do

  let(:rss) do
    <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <rss xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
        <channel>
          <title>Bamboo build results feed for all builds</title>
          <link>http://example.com</link>
          <description>This feed is updated whenever a build gets built</description>
          <item>
            <title>FOO-BAR-22 was SUCCESSFUL : Scheduled build</title>
            <link>http://example.com/browse/FOO-BAR-22</link>
            <guid>http://example.com/browse/FOO-BAR-22</guid>
            <pubDate>Sun, 03 Mar 2013 22:30:35 GMT</pubDate>
            <dc:date>2013-03-03T22:30:35Z</dc:date>
          </item>
          <item>
            <title>CUTE-KITTIES-999 has FAILED : Scheduled build</title>
            <link>http://example.com/browse/CUTE-KITTIES-999</link>
            <guid>http://example.com/browse/CUTE-KITTIES-999</guid>
            <pubDate>Sun, 03 Mar 2013 22:21:10 GMT</pubDate>
            <dc:date>2013-03-03T22:21:10Z</dc:date>
          </item>
        </channel>
      </rss>
    XML
  end

  describe "#parse" do

    let(:result) do
      Bamboozled::FeedParser.parse(StringIO.new(rss))
    end

    it "returns info for each listed build" do
      result.should have(2).elements
    end

    it "returns the name of each build" do
      result.map(&:name).should eq(%w(FOO-BAR CUTE-KITTIES))
    end

    it "returns the status of each build" do
      result.map(&:status).should eq([:success, :failure])
    end

    it "returns the URL of each build" do
      result.map(&:url).should eq([
        "http://example.com/browse/FOO-BAR-22",
        "http://example.com/browse/CUTE-KITTIES-999"
      ])
    end

  end

end
