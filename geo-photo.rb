#! /usr/bin/env ruby

def decimal2degrees(coordinate, value, return_hash=false)
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
        exif_info["GPSLatitude"] = "#{unit}, #{minutes}, #{seconds}"
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

puts google2lightroom("https://www.google.com/maps/place/42%C2%B005'06.0%22N+71%C2%B040'06.0%22W/@42.085,-71.6683333,15z/data=!3m1!4b1!4m2!3m1!1s0x0:0x0")

# End of script
