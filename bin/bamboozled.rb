#! /usr/bin/env ruby

require "rubygems"
require "open-uri"

$: << File.join(File.dirname(__FILE__), "..", "lib")

require "bamboozled/feed_parser"

def load_builds(bamboo_server)
  open("http://#{bamboo_server}/rss/createAllBuildsRssFeed.action?feedType=rssAll") do |rss_stream|
    Bamboozled::FeedParser.parse(rss_stream)
  end
end

require "builder"

def generate_cctray_xml(builds)
  _ = Builder::XmlMarkup.new(:indent => 2)
  _.Projects do
    builds.each do |build|
      _.Project({
        :name => build.name,
        :activity => "Sleeping",
        :lastBuildStatus => build.status.to_s.capitalize,
        :webUrl => build.url
      })
    end
  end
end

require "sinatra"

get "/" do
  erb :index
end

get "/:server_host_and_port/cc.xml" do |server_host_and_port|
  build_info = begin
    load_builds(server_host_and_port)
  end
  content_type 'application/xml'
  generate_cctray_xml(build_info)
end

__END__

@@ index
<h1>Bamboozled</h1>

<p>
  Bamboozled is a simple adapter for build results from Bamboo, making them available in CruiseControl
  XML format.
</p>

<p>
  Just point your CCTray or CCMenu at:
</p>

<pre>
    <%= url("/${bamboo_host}/cc.xml") %>
</pre>
