require "bamboozled/telemetry_fetcher"
require "builder"
require "sinatra/base"

module Bamboozled

  class App < Sinatra::Base

    enable :inline_templates

    get "/" do
      content_type 'text/plain'
      erb :index
    end

    get "/:server_host_and_port/cc.xml" do |server_host_and_port|
      build_info = begin
        load_plans(server_host_and_port)
      end
      content_type 'application/xml'
      generate_cctray_xml(build_info)
    end

    private

    def load_plans(bamboo_server)
      Bamboozled::TelemetryFetcher.new("http://#{bamboo_server}").fetch
    end


    def generate_cctray_xml(plans)
      _ = Builder::XmlMarkup.new(:indent => 2)
      _.Projects do
        plans.each do |build|
          _.Project(
            :name => build.name,
            :activity => build.activity,
            :lastBuildStatus => build.status,
            :lastBuildTime => build.last_build_time,
            :webUrl => build.url
          )
        end
      end
    end

  end

end

__END__

@@ index

                           ------------
                            Bamboozled
                           ------------

    Bamboozled grabs build results from an Atlassian Bamboo server,
    and re-publishes them in "cc.xml" format, making them available
    to tools like "CCMenu" and "CCTray".

    Just point your CCMenu/CCTray at:

      <%= url("/${bamboo_host_of_your_choice}/cc.xml") %>

    where ${bamboo_host_of_your_choice} is a Bamboo host of your choice.

