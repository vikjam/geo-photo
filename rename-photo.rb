#! /usr/bin/env ruby
require 'mini_exiftool'
require 'time'
require 'csv'
require 'ruby-progressbar'
require 'fileutils'

# Define the file path
puts "What is the full file path to the folder?"
file_path = gets
file_path = file_path.chomp

# Make a new folder to dump the RAWs
FileUtils.mkdir_p "#{file_path}/RAW"

# Create an array to store metadata for a .csv
rows = [["file_path", "file_extension"]]

# Create progress bar
progressbar = ProgressBar.create(
    total: Dir.glob("#{file_path}/*.{JPG,NEF,MOV}").length
)

# Loop over all media files
Dir.glob("#{file_path}/*.{JPG,NEF,MOV}") do |pic_file|

    pic = MiniExiftool.new pic_file
    time = pic.date_time_original
    dt = time.strftime('%Y-%m-%d_%H-%M-%S')
    file_extension = File.extname(pic_file)
    new_file = "#{dt}-#{File.basename(pic_file)}"

    if file_extension == ".NEF"
        FileUtils.move pic_file, "#{file_path}/RAW/#{new_file}"
    else
        FileUtils.move pic_file, "#{file_path}/#{new_file}"
    end

    rows << [new_file, file_extension]

    progressbar.increment
end

File.write("#{file_path}/photo-geo.csv", rows.map(&:to_csv).join)
