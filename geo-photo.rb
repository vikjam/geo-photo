#! /usr/bin/env ruby
require 'csv'
require 'mini_exiftool'

def decimal2degrees(coordinate, value)
  decimal = value.to_f
  unit    = decimal.to_i.abs.to_s
  minutes = "%02d"   % (decimal.abs * 60).to_i.modulo(60)
  seconds = "%02.4f" % (decimal.abs * 3600).modulo(60)

  if coordinate.downcase() == "latitude"
    direction = decimal < 0 ? "S" : "N"
  elsif coordinate.downcase() == "longitude"
    direction = decimal < 0 ? "W" : "E"
  else
    raise "Hey, that's neither 'latitude' nor 'longitude'."
  end

  return direction, unit, minutes, seconds
end

class GoogleMapsLink
    attr_accessor :GPSLatitudeRef
    attr_accessor :GPSLatitudeUnit
    attr_accessor :GPSLatitudeMinutes
    attr_accessor :GPSLatitudeSeconds
    attr_accessor :GPSLongitudeRef
    attr_accessor :GPSLongitudeUnit
    attr_accessor :GPSLongitudeMinutes
    attr_accessor :GPSLongitudeSeconds

  def initialize(google_url)
    @google_url = google_url
    @decimal_latitude, @decimal_longitude = @google_url[/@.*z/].gsub('@', '').split(',')[0..1]
    @GPSLatitudeRef,
      @GPSLatitudeUnit,
      @GPSLatitudeMinutes,
      @GPSLatitudeSeconds = decimal2degrees("latitude", @decimal_latitude)
    @GPSLongitudeRef,
      @GPSLongitudeUnit,
      @GPSLongitudeMinutes,
      @GPSLongitudeSeconds = decimal2degrees("longitude", @decimal_longitude)
  end

  def to_lightroom
    l = "#{@GPSLatitudeUnit}°#{@GPSLatitudeMinutes}'#{@GPSLatitudeSeconds}\"#{@GPSLatitudeRef}, " + 
        "#{@GPSLongitudeUnit}°#{@GPSLongitudeMinutes}'#{@GPSLongitudeSeconds}\"#{@GPSLongitudeRef}"
  end
end

def append_googlemaps(photo, link)
  photo.GPSLatitudeRef = link.GPSLatitudeRef
  photo.GPSLatitude = "#{link.GPSLatitudeUnit}, "    + 
                      "#{link.GPSLatitudeMinutes}, " +
                      "#{link.GPSLatitudeSeconds}"
  photo.GPSLongitudeRef = link.GPSLongitudeRef
  photo.GPSLongitude = "#{link.GPSLongitudeUnit}, "    + 
                       "#{link.GPSLongitudeMinutes}, " +
                       "#{link.GPSLongitudeSeconds}"
  photo.save
end

def from_csv(csv_path)
  CSV.read(csv_path).each do | row |
    g = GoogleMapsLink.new(row[1])
    puts "#{row[0]} | #{row[1]} | #{g.to_lightroom}"
  end
end

from_csv("/Users/vikjam/Desktop/Nikon/geo.csv")

# End of script
