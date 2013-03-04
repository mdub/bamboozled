require "rss"

module Bamboozled

  class FeedParser

    def self.parse(rss)
      new.parse(rss)
    end

    def parse(rss)
      feed = RSS::Parser.parse(rss)
      feed.items.map do |item|
        ProjectInfo.new(item)
      end
    end

    class ProjectInfo

      def initialize(rss_item)
        if rss_item.title =~ /^(\S+)-\d+ /
          @name = $1
        end
        @status = case rss_item.title
        when / was SUCCESSFUL /
          :success
        when / has FAILED /
          :failure
        end
        @url = rss_item.link
      end

      attr_reader :name
      attr_reader :status
      attr_reader :url

    end

  end

end
