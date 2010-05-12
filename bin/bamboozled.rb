#! /usr/bin/env ruby

require "rubygems"

require "nokogiri"
require "open-uri"

class BuildStatus
  attr_reader :label, :successful, :url
  def initialize(label, successful, url)
    @label = label
    @successful = successful
    @url = url
  end
end

def load_builds(bamboo_server)
  telemetry_url = "#{bamboo_server}/telemetry.action"
  telemetry_stream = begin
    open(telemetry_url)
  rescue StandardError
    return []
  end

  builds = []

  doc = Nokogiri::HTML.parse(telemetry_stream)
  doc.xpath("//tr").map do | tr |
    successful = tr.attributes["class"] == "Successful"
    a = (tr.xpath("td/a"))[0]
    name = a.inner_html
    url = bamboo_server + a.attributes["href"]
    BuildStatus.new(name, successful, url)
  end
end

require "builder"

def generate_cctray_xml(builds)
  _ = Builder::XmlMarkup.new(:indent => 2) 
  _.Projects do
    builds.each do |build|
      _.Project({
        :name => build.label, 
        :activity => "Sleeping", 
        :lastBuildStatus => build.successful ? "Success" : "Failure", 
        :webUrl => build.url
        })
    end
  end
end

require "sinatra"

get "/:server_host_and_port/cc.xml" do |server_host_and_port|
  build_info = load_builds("http://#{server_host_and_port}")
  content_type 'application/xml'
  generate_cctray_xml(build_info)
end
