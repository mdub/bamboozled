require "bamboozled/build_results_parser"
require "bamboozled/telemetry_fetcher"
require "haml"
require "multi_json"
require "sinatra/base"
require "rest-client"

module Bamboozled

  class App < Sinatra::Base

    set :views, File.expand_path("../templates", __FILE__)

    get "/" do
      content_type 'text/plain'
      erb :"index.txt"
    end

    get "/:server/cc.xml" do
      server_host_and_port = params[:server]
      @build_info = begin
        load_plans(server_host_and_port, request.query_string)
      end
      content_type 'application/xml'
      builder :"cc.xml"
    end

    get "/:server/plans/:plan" do
      url = "#{params[:server]}/rest/api/latest/result/#{params[:plan]}.json?includeAllStates=true&expand=results[0:4].result.stages"
      @results = BuildResultsParser.parse(RestClient.get(url))
      haml :"summary.html"
    end

    private

    def load_plans(bamboo_server, query_string)
      Bamboozled::TelemetryFetcher.new("http://#{bamboo_server}/telemetry.action?#{query_string}").fetch
    end

  end

end

require "bamboozled/test_fixtures"
