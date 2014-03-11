require "bundler/setup"

require "rubygems"

$: << File.join(File.dirname(__FILE__), "lib")

require "bamboozled/app"

run Bamboozled::App
