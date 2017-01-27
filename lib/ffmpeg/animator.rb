require 'open3'

module FFMPEG
  class Animator < FFMPEG::Transcoder

    def initialize(input, output_file, options = EncodingOptions.new, animate_options = {}, palette_use = false)
      super(input, output_file, options, animate_options)
      @paletteuse = palette_use
    end

    def run(&block)

      base_command = [FFMPEG.ffmpeg_binary, *@raw_options.to_a, '-i', @input]

      if @paletteuse
        
        palette = File.join(File.dirname(@output_file), File.basename(@output_file).delete(File.extname(@output_file))) + '.png'

        @command = (base_command + ['-an', '-vf', 'palettegen', '-y', palette]).join(' ')
        transcode_movie(&block)

        base_command += ['-i', palette]
      end

      iopts = (@transcoder_options[:input_options] || {}).collect {|k, v| "#{k}=#{v}"}.join(',')
      iopts = 'paletteuse,' + iopts if @paletteuse

      @command = (base_command + ['-an', '-lavfi', iopts, '-y', @output_file]).join(' ')
      transcode_movie(&block)
      File.unlink palette if @paletteuse
    end
  end
end
