require "bamboozled/project_info"
require "nokogiri"
require "open-uri"

module Bamboozled

  class TelemetryFetcher

    def initialize(base_url)
      @base_url = base_url
    end

    def fetch
      html = open("#{base_url}/telemetry.action").read
      doc = Nokogiri::HTML.parse(html)
      doc.css("div.build").map do |build_node|
        plan_name_node = build_node.css(".plan-name").first
        result_status_class = build_node.css(".result").first[:class].split.last
        activity = if build_node.css(".indicator.building").first
          "Building"
        else
          "Sleeping"
        end
        ProjectInfo.with(
          name: plan_name_node.text,
          url: base_url + plan_name_node[:href],
          status: STATUS_MAP.fetch(result_status_class, "Unknown"),
          activity: activity
        )
      end
    end

    private

    attr_reader :base_url

    STATUS_MAP = {
      "Successful" => "Success",
      "Failed" => "Failure"
    }

  end

end
