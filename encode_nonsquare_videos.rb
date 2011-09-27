#!/usr/bin/ruby

# Allows encoding e.g. MPEG-2 files with non-square pixels at the correct aspect ratio.
# This is done by extracting a few frames from the middle of the video to find the correct aspect ratio,
# then setting this aspect ratio explicitly when encoding with ffmpeg.
#
# Requirements: ffmpeg in /usr/local/bin 
#               Needs to be compiled with faad, x264
# Usage:
# require 'encode_nonsquare_videos'
# Ffmpeg.encode(source_filename, destination_filename)
#
# At the moment, you must set your encode options directly in Ffmpeg#build_command


class Ffmpeg
  # How many threads to use -- speeds things up on multi-core/multi-CPU machines
  @@threads = 0

  def self.extract_sar(filename)
    # DANGER: Assumes that the video is at least 60 seconds long, and tries to grab some frame from the middle to reliably
    # determine aspect ratio
    sample_aspect_ratio = `/usr/local/bin/ffmpeg -vf showinfo -ss 60 -t 1 -i #{filename} -y /tmp/temp.m4v 2>&1 | grep "sar:" | grep -v sws_param | cut -d " " -f 9 | uniq`.split("\n").last.gsub("sar:","")
    sample_aspect_ratio.gsub!("64/45","16:9")
    sample_aspect_ratio.gsub!("16/15","4:3")
  end

  def self.encode(filename, destdir = "./")
    commands = self.build_commands(filename, destdir)
    commands.each do |command|
      puts "Running #{command}"
      result = `#{command}`
    end
  end

  def self.build_commands(filename, destdir)
    commands = []
    output_basename = File.basename(filename, File.extname(filename))
    aspect_ratio = Ffmpeg.extract_sar(filename).gsub("/",":")
    deinterlace = '-vf "yadif=3"'
    video_codec = "-vcodec libx264"
    audio_codec = "-acodec libfaac -ab 160k"
    #quality = "-qscale 18" # You could also put things like bitrate here instead if you want control over that
    quality = "-crf 20 -preset slow"

    # This command encodes without audio to an MP4 container
    #commands << "/usr/local/bin/ffmpeg -i #{filename} #{deinterlace} #{video_codec} -an -threads #{@@threads} #{quality} #{destdir}/#{output_basename}.mp4"

    # This encodes just the audio to an AAC file
    #commands << "/usr/local/bin/ffmpeg -i #{filename} #{deinterlace} -threads #{@@threads} #{audio_codec} #{destdir}/#{output_basename}.aac"

    # This command encodes with audio to an MP4 container
    commands << "/usr/local/bin/ffmpeg -i #{filename} #{deinterlace} #{video_codec} #{audio_codec} -threads #{@@threads} #{quality} -aspect #{aspect_ratio} #{destdir}/#{output_basename}.m4v"
    
    return commands
    
  end
  
end
