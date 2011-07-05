#!/usr/bin/ruby

# Allows encoding e.g. MPEG-2 files with non-square pixels at the correct aspect ratio.
# This is done by extracting a few frames from the middle of the video to find the correct aspect ratio,
# then setting this aspect ratio explicitly when encoding with ffmpeg.
#
# Requirements: ffmpeg, mplayer in your $PATH
#
# Usage:
# require 'encode_nonsquare_videos'
# Ffmpeg.encode(source_filename, destination_filename)
#
# At the moment, you must set your encode options directly in Ffmpeg#build_command

class Mplayer

  attr_accessor :filename
  attr_reader :info

  def initialize(filename = nil)
    @filename = filename
    @info = {}

    self.extract_information unless @filename.empty?
  end

  def extract_information
    if @filename
      initial_info = `mplayer -vo null -ao null -frames 0 -identify #{@filename} 2>/dev/null | grep ID_`
      initial_info.each do |info|
        key, value = info.split("=")
        value = value.gsub("\n","")
        key = key.gsub("ID_", "")
        @info.merge!(:"#{key.downcase}" => value)
      end
      # We play a few frames from the middle of the clip because only that gives us the correct aspect ratio.
      # These crazy MPEG-2 PS files can switch aspect ratio at any time!
      aspect_ratio = `mplayer -vo null -ao null -ss #{@info[:length].to_i / 2} -frames 4 -identify #{@filename} 2>/dev/null | grep ID_VIDEO_ASPECT`
      ratios = []
      aspect_ratio.each do |ar|
        key, value = ar.split("=")
        value = value.gsub("\n","")
        ratios << value.to_f
      end
      @info[:video_aspect] = ratios.last
      return true
    elsif !File.exists?(@filename)
      puts "Sorry, the file '#{@filename}' does not exist."
      return false
    else
      puts "Sorry, can't extract information if I don't have a filename."
      return false
    end
    
  end

end


class Ffmpeg
  # How many threads to use -- speeds things up on multi-core/multi-CPU machines
  @@threads = 0

  def self.encode(filename, destination)
    command = self.build_command(filename, destination)
    puts "Running #{command}"
    result = `#{command}`
    if $? == 0
      return true
    else
      puts result
      return false
    end
  end

  def self.build_command(filename, destination)
    aspect_ratio = Mplayer.new(filename).info[:video_aspect]
    deinterlace = '-vf "yadif=3"'
    video_codec = "-vcodec libx264"
    audio_codec = "-acodec libfaac -ab 160k"
    #quality = "-qscale 18" # You could also put things like bitrate here instead if you want control over that
    quality = "-crf 17 -preset slow"

    return "/usr/local/bin/ffmpeg -i #{filename} #{deinterlace} #{video_codec} -threads #{@@threads} #{audio_codec} #{quality} -aspect #{aspect_ratio} #{destination}"
  end
  
end
