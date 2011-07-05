#!/usr/bin/ruby

# Allows encoding e.g. MPEG-2 files with non-square pixels at the correct aspect ratio.
# This is done by extracting a few frames from the middle of the video to find the correct aspect ratio,
# then setting this aspect ratio explicitly when encoding with ffmpeg.
#
# Requirements: ffmpeg, mplayer in your $PATH
#
# Usage:
# Ffmpeg.encode(source_filename, destination_filename)


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
  @@threads = 8

  def self.encode(filename, destination)
    aspect_ratio = Mplayer.new(filename).info[:video_aspect]
    deinterlace = '-vf "yadif=3"'
    command = "ffmpeg -i #{filename} -threads #{@@threads} -crf 17.0 -qcomp 0.6 -b 5000KB #{deinterlace} -aspect #{aspect_ratio} -deinterlace -vc h264 -acodec libfaac -ab 160k #{destination}"
    result = `#{command}`
  end
end
