require 'open3'

module FFMPEG
  class Animator < FFMPEG::Transcoder

    def initialize(input, output_file, options = EncodingOptions.new, animate_options = {}, palette_options = {})
      super(input, output_file, options, animate_options)
      @palette_options = palette_options
    end

    def run(&block)

      @paletteuse = !@palette_options.empty?

      base_command = [FFMPEG.ffmpeg_binary, *@raw_options.to_a, '-i', @input]

      if @paletteuse
        # ffmpeg -ss 1556 -t 5 -vf palettegen,fps=10,scale=480:-1:flags=lanczos -i ./123016_003-caribpr-1080p.mp4 -y ./nak846_1.png

        palette = File.join(File.dirname(@input), File.basename(@input).gsub(File.extname(@input), '')) + '.png'
        iopts = @palette_options.collect {|k, v| "#{k}=#{v}"}.join(',')

        @command = (base_command + ['-vf', 'palettegen,' + iopts, '-y', palette]).join(' ')
        transcode_movie(&block)

        base_command += ['-i', palette]
      end

      iopts = (@transcoder_options[:input_options] || {}).collect {|k, v| "#{k}=#{v}"}.join(',')
      iopts = 'paletteuse,' + iopts if @paletteuse

      # ffmpeg -ss 1556 -t 5 -lavfi paletteuse,fps=10,scale=480:-1:flags=lanczos -i ./123016_003-caribpr-1080p.mp4 -i nak846_1.png -y ./nak846_1.gif
      @command = (base_command + ['-lavfi', iopts, '-y', @output_file]).join(' ')
      transcode_movie(&block)
      File.unlink palette if @paletteuse
    end
  end
end
