#! /usr/bin/env ruby
require 'csv'
require 'mini_exiftool'
require 'ruby-progressbar'

# Define the file path
puts "What is the full file path to the folder?"
file_path = gets
file_path = file_path.chomp

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
    @decimal_latitude, @decimal_longitude = @google_url[/@.*(z|m)/].gsub('@', '').split(',')[0..1]
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

def append_googlemaps(photo_ref, url)
  photo = MiniExiftool.new photo_ref
  link  = GoogleMapsLink.new(url)
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

def csv2lightroom(csv_path)
  CSV.read(csv_path).each do | row |
    g = GoogleMapsLink.new(row[1])
    puts "#{row[0]} | #{row[1]} | #{g.to_lightroom}"
  end
end

# Create progress bar
progressbar = ProgressBar.create(
    total: CSV.read("#{file_path}/photo-geo.csv", headers: true).count
)

CSV.read("#{file_path}/photo-geo.csv", headers: true).each do | row |
  g = GoogleMapsLink.new(row[2])
  progressbar.log "#{row[0]} | #{row[1]} | #{g.to_lightroom}"
  append_googlemaps("#{file_path}/#{row[0]}", row[2])
  progressbar.increment
end

# End of script
