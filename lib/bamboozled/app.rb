require "bamboozled/telemetry_fetcher"
require "builder"
require "sinatra/base"

module Bamboozled

  class App < Sinatra::Base

    set :views, File.expand_path("../templates", __FILE__)

    get "/" do
      content_type 'text/plain'
      erb :"index.txt"
    end

    get "/*/cc.xml" do
      server_host_and_port = params[:splat].first
      build_info = begin
        load_plans(server_host_and_port, request.query_string)
      end
      content_type 'application/xml'
      generate_cctray_xml(build_info)
    end

    private

    def load_plans(bamboo_server, query_string)
      Bamboozled::TelemetryFetcher.new("http://#{bamboo_server}/telemetry.action?#{query_string}").fetch
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
