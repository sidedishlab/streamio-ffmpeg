require 'open3'
require 'rmagick' if defined?(Magick)

module FFMPEG
  class Animator2 < FFMPEG::Transcoder

    def run(&block)

      name = File.basename(@output_file).delete(File.extname(@output_file))
      stream_dir = File.join(File.dirname(@output_file), name)

      begin

        FileUtils.mkdir_p(stream_dir) unless FileTest.exist?(stream_dir)

        # ffmpeg -i 入力.mp4 -an -r 15 -s 320x180 %04d.png
        transcoder_options = @transcoder_options[:input_options]
        iopts = (transcoder_options || {}).collect {|k, v| "#{k}=#{v}"}.join(',')
        @command = [FFMPEG.ffmpeg_binary, *@raw_options.to_a, '-i', @input, '-an', '-vf', iopts, File.join(stream_dir, '%04d.png')]
        transcode_movie(&block)

        # convert *.png アニメ.gif
        output = Magick::ImageList.new
        Dir.glob(File.join(stream_dir, '*')).sort.each do |image|
          # output.push Magick::Image.read(image).first
          output.concat Magick::ImageList.new(image)
        end

        binding.pry

        output.delay = (20 - transcoder_options[:fps]).abs if transcoder_options && transcoder_options[:fps]
        output.write @output_file
        
      rescue => e
        p e.message
      ensure
        File.unlink *Dir.glob(File.join(stream_dir, '*'))
        Dir.rmdir stream_dir
      end
    end
  end
end
