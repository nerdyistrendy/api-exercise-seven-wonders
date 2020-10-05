require 'httparty'
require "awesome_print"
require 'dotenv'
require "prettyprint"

Dotenv.load

BASE_URL = "https://us1.locationiq.com/v1/search.php"
LOCATION_IQ_KEY = ENV["key"]

class SearchError < StandardError; end

def get_location(search_term)
  query= {
      key: LOCATION_IQ_KEY,
      q: search_term,
      format: "json"
  }

  response = HTTParty.get(BASE_URL, query: query)

  unless response.code == 200
    raise SearchError, "Cannot find #{search_term}"
  end

  location = {search_term => {:lat => response[0]["lat"],
                              :lon => response[0]["lon"]
                              }}
  return location
end

def find_seven_wonders

  seven_wonders = ["Great Pyramid of Giza", "Gardens of Babylon", "Colossus of Rhodes", "Pharos of Alexandria", "Statue of Zeus at Olympia", "Temple of Artemis", "Mausoleum at Halicarnassus"]

  seven_wonders_locations = []

  seven_wonders.each do |wonder|
    sleep(0.5)
    seven_wonders_locations << get_location(wonder)
  end

  return seven_wonders_locations
end

def driving_directions(coordinates)
  url = "https://us1.locationiq.com/v1/directions/driving/#{coordinates}"
  query= {key: LOCATION_IQ_KEY}
  sleep(1.0)
  response = HTTParty.get(url, query: query)
  return response
end

def get_coordinates(search1, search2)
  l1 = get_location(search1)[search1]
  l2 = get_location(search2)[search2]
  coordinates = "#{l1[:lat]},#{l1[:lon]};#{l2[:lat]},#{l1[:lon]}"
  return coordinates
end


def coordinates_to_name(locations)
  url = 'https://us1.locationiq.com/v1/reverse.php'
  place_name = []
  locations.each do |location|
    lat = location[:lat]
    lon = location[:lon]
    query= {
        key: LOCATION_IQ_KEY,
        lat: lat,
        lon: lon,
        format: "json"
    }
    sleep(0.5)
    place_name << {location => HTTParty.get(url, query: query)["display_name"]}
  end
  return place_name
end

# Use awesome_print because it can format the output nicely
ap find_seven_wonders
# Expecting something like:
# [{"Great Pyramid of Giza"=>{:lat=>"29.9791264", :lon=>"31.1342383751015"}}, {"Gardens of Babylon"=>{:lat=>"50.8241215", :lon=>"-0.1506162"}}, {"Colossus of Rhodes"=>{:lat=>"36.3397076", :lon=>"28.2003164"}}, {"Pharos of Alexandria"=>{:lat=>"30.94795585", :lon=>"29.5235626430011"}}, {"Statue of Zeus at Olympia"=>{:lat=>"37.6379088", :lon=>"21.6300063"}}, {"Temple of Artemis"=>{:lat=>"32.2818952", :lon=>"35.8908989553238"}}, {"Mausoleum at Halicarnassus"=>{:lat=>"37.03788265", :lon=>"27.4241455276707"}}]

coordinates = get_coordinates("Cairo Egypt", "Great Pyramid of Giza")
pp driving_directions(coordinates)

locations = [{ lat: 38.8976998, lon: -77.0365534886228}, {lat: 48.4283182, lon: -123.3649533 }, { lat: 41.8902614, lon: 12.493087103595503}]
ap coordinates_to_name(locations)

