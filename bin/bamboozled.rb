#! /usr/bin/env ruby

require "rubygems"

$: << File.join(File.dirname(__FILE__), "..", "lib")

require "bamboozled/telemetry_fetcher"

module Enumerable

  # from activesupport/lib/active_support/core_ext/array/uniq_by.rb
  def uniq_by
    hash, array = {}, []
    each { |i| hash[yield(i)] ||= (array << i) }
    array
  end

end

def load_plans(bamboo_server)
  Bamboozled::TelemetryFetcher.new("http://#{bamboo_server}").fetch
end

require "builder"

def generate_cctray_xml(plans)
  _ = Builder::XmlMarkup.new(:indent => 2)
  _.Projects do
    plans.each do |build|
      _.Project({
        :name => build.name,
        :activity => "Sleeping",
        :lastBuildStatus => build.status,
        :lastBuildTime => build.last_build_time,
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
    load_plans(server_host_and_port)
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
