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
    raise "Hey, that's neither 'latitude' nor 'longitude'!"
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
      @GPSLongitudeSeconds = decimal2degrees("longitude", @decimal_latitude)
  end

  def to_lightroom
    l = "#{@GPSLatitudeUnit}°#{@GPSLatitudeMinutes}'#{@GPSLatitudeSeconds}\"#{@GPSLatitudeRef}, " + 
        "#{@GPSLongitudeUnit}°#{@GPSLongitudeMinutes}'#{@GPSLongitudeSeconds}\"#{@GPSLongitudeRef}"
  end
end

# def append_googlemaps(photo, link)
#   photo.GPSLatitudeRef = link.GPSLatitudeRef
#   photo.GPSLatitude = "#{link.GPSLatitudeUnit}, "    + 
#                      "#{link.GPSLatitudeMinutes}, " +
#                      "#{link.GPSLatitudeSeconds}"

#   photo.GPSLongitudeRef = link.GPSGPSLongitudeRef
#   photo.GPSLongitude = "#{link.GPSLongitudeUnit}, "    + 
#                       "#{link.GPSLongitudeMinutes}, " +
#                       "#{link.GPSLongitudeSeconds}"
# end


photo = MiniExiftool.new("/Users/vikjam/Desktop/Nikon/DSC_0085.NEF")
link = GoogleMapsLink.new("https://www.google.com/maps/place/Worcester,+MA/@42.2754349,-71.808442,12z/")
photo.GPSLatitudeRef = link.GPSLatitudeRef
photo.GPSLatitude = "#{link.GPSLatitudeUnit}, "     + 
                     "#{link.GPSLatitudeMinutes}, " +
                     "#{link.GPSLatitudeSeconds}"

photo.GPSLongitudeRef = link.GPSLongitudeRef
photo.GPSLongitude = "#{link.GPSLongitudeUnit}, "    + 
                     "#{link.GPSLongitudeMinutes}, " +
                     "#{link.GPSLongitudeSeconds}"
photo.save

# End of script
