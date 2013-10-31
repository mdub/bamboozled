require "bamboozled/project_info"
require "nokogiri"
require "open-uri"

module Bamboozled

  class TelemetryFetcher

    def initialize(telemetry_url, headers = {})
      @telemetry_url = telemetry_url
      @base_url = telemetry_url.sub(%r{/telemetry.*}, '')
      @headers = headers
    end

    def fetch
      html = open(telemetry_url, headers).read
      doc = Nokogiri::HTML.parse(html)
      doc.css("div.build").map do |build_node|

        plan_name_node = build_node.css(".plan-name").first
        project_name = build_node.css(".project-name").text

        info = {
          :name => "#{project_name} - #{plan_name_node.text}",
          :url => base_url + plan_name_node[:href],
          :key => File.basename(plan_name_node[:href])
        }

        result_status_class = build_node.css(".result").first[:class].split.last
        info[:status] = STATUS_MAP.fetch(result_status_class, "Unknown")

        info[:activity] = if build_node.css(".indicator.building").first
          "Building"
        else
          "Sleeping"
        end

        time_node = build_node.css("time").first
        info[:last_build_time] = time_node[:datetime] if time_node

        ProjectInfo.with(info)

      end
    end

    private

    attr_reader :telemetry_url, :base_url, :headers

    STATUS_MAP = {
      "Successful" => "Success",
      "Failed" => "Failure"
    }

  end

end
