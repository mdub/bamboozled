#! /usr/bin/env ruby

require "rubygems"

require "hpricot"
require "open-uri"

BuildStatus = Struct.new(:label, :status, :url)

def load_builds(bamboo_server)
  telemetry_doc = Hpricot(open("#{bamboo_server}/telemetry.action"))

  builds = []

  telemetry_doc.search("//tr").map do | tr |
    status = tr.attributes["class"] == "Successful" ? "Success" : "Failure"
    a = (tr.search("td/a"))[0]
    name = a.inner_html
    url = bamboo_server + a.attributes["href"]
    BuildStatus.new(name, status, url)
  end
end

bamboo_server = "http://ci.au.lpint.net:8085"

require "builder"
builds = load_builds(bamboo_server)

xml = Builder::XmlMarkup.new(:target => STDOUT, :indent => 2) 
xml.Projects do
  builds.each do |build|
    xml.Project(:name => build.label, :activity => "Sleeping", :lastBuildStatus => build.status, :webUrl => build.url)
  end
end

