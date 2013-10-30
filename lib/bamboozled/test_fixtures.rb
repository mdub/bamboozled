require 'sham_rack'

test_fixtures = File.expand_path("../../../spec/fixtures", __FILE__)

ShamRack.at("bamboo.example.com").sinatra do

  get "/rest/api/latest/result/:plan.json" do
    results_file = File.join(test_fixtures, "results-#{params[:plan]}.json")
    halt 404 unless File.exist?(results_file)
    content_type 'application/json'
    File.read(results_file)
  end

end
