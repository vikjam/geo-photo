#! /usr/bin/env ruby
require 'csv'
require 'mini_exiftool'

def decimal2degrees(coordinate, value, return_hash = false)
    decimal = value.to_f
    unit    = decimal.to_i.abs.to_s
    minutes = "%02d"   % (decimal.abs * 60).to_i.modulo(60)
    seconds = "%02.4f" % (decimal.abs * 3600).modulo(60)

    exif_info = Hash.new

    if coordinate.downcase() == "lat"
        direction = ""
        if decimal < 0
            direction = "S"
        else
            direction = "N"
        end
        exif_info["GPSLatitudeRef"] = direction
        exif_info["GPSLatitude"]    = "#{unit}, #{minutes}, #{seconds}"
    elsif coordinate.downcase() == "long"
        if decimal > 0
            direction = "E"
        else
            direction = "W"
        end
        exif_info["GPSLongitudeRef"] = direction
        exif_info["GPSLatitude"] = "#{unit}, #{minutes}, #{seconds}"
    end
    
    if return_hash
        return exif_info
    else
        return "#{unit}°#{minutes}'#{seconds}\"#{direction}"
    end

end

def google2lightroom(theurl)
    geo_str = theurl[/@.*z/]
    dec_lat, dec_long = geo_str.gsub('@', '').split(',')[0..1]
    deg_lat, deg_long = decimal2degrees("lat", dec_lat), decimal2degrees("long", dec_long)
    return "#{deg_lat} #{deg_long}"
end

# puts google2lightroom("https://www.google.com/maps/search/199+Prospect+St,+Cambridge,+MA/@42.0369215,-71.6835014,8z")

# CSV.read("/Users/vikjam/Desktop/Nikon/geo.csv", "r").each do | row |
#     puts "#{row[0]}, #{row[1]}, #{google2lightroom(row[1])}"
# end

class GoogleMapsLink

  def initialize(google_url)
    @google_url = google_url
    @decimal_latitude, @decimal_longitude = @google_url[/@.*z/].gsub('@', '').split(',')[0..1]
  end

  def puts_link()
    puts "#{@decimal_latitude}, #{@decimal_longitude}"
  end

end

g = GoogleMapsLink.new("https://www.google.com/maps/search/199+Prospect+St,+Cambridge,+MA/@42.0369215,-71.6835014,8z")
puts g.puts_link()

photo = MiniExiftool.new("/Users/vikjam/Desktop/Nikon/DSC_0085.NEF")

photo.save

# End of script
