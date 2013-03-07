require "rss"
require "bamboozled/project_info"

module Bamboozled

  class FeedParser

    def self.parse(rss)
      new.parse(rss)
    end

    def parse(rss)
      feed = RSS::Parser.parse(rss)
      feed.items.map(&method(:extract_info))
    end

    private

    def extract_info(rss_item)
      name = if rss_item.title =~ /^(\S+)-\d+ /
        $1
      end
      status = case rss_item.title
      when / was SUCCESSFUL /
        :success
      when / has FAILED /
        :failure
      end
      ProjectInfo.with(
        name: name,
        status: status,
        url: rss_item.link
      )
    end

  end

end
