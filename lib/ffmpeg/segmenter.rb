require 'open3'

module FFMPEG
  class Segmenter
    attr_reader :command, :input

    @@timeout = 30

    class << self
      attr_accessor :timeout
    end

    def initialize(input, output_playlist, output_filename, segmenter_options = SegmentOptions.new)

      if input.is_a?(FFMPEG::Movie)
        @movie = input
        @input = input.path
      end

      if segmenter_options.is_a?(Array) || segmenter_options.is_a?(SegmentOptions)
        @raw_options = segmenter_options
      elsif segmenter_options.is_a?(Hash)
        @raw_options = SegmentOptions.new(segmenter_options)
      else
        raise ArgumentError, "Unknown segmenter_options format '#{segmenter_options.class}', should be either SegmentOptions, Hash or Array."
      end

      @command = [FFMPEG.ffmpeg_binary, '-i', @input, '-f segment', "-segment_list #{output_playlist.to_s}", *@raw_options.to_a, output_filename.to_s]
    end

    def run(&block)
      segment_movie(&block)
    end

    def timeout
      self.class.timeout
    end

    private

      # frame= 4855 fps= 46 q=31.0 size=45306kB time=00:02:42.28 bitrate=2287.0kbits/
      def segment_movie
        FFMPEG.logger.info("Running segmenting...\n#{command}\n")
        @output = ''

        Open3.popen3(command.join(' ')) do |_stdin, _stdout, stderr, wait_thr|
          begin
            yield(0.0) if block_given?
            next_line = Proc.new do |line|
              @output << line
              if line.include?('time=')
                if line =~ /time=(\d+):(\d+):(\d+.\d+)/ # ffmpeg 0.8 and above style
                  time = ($1.to_i * 3600) + ($2.to_i * 60) + $3.to_f
                else # better make sure it wont blow up in case of unexpected output
                  time = 0.0
                end

                if @movie
                  progress = time / @movie.duration
                  yield(progress) if block_given?
                end
              end
            end

            if timeout
              stderr.each_with_timeout(wait_thr.pid, timeout, 'size=', &next_line)
            else
              stderr.each('size=', &next_line)
            end

          rescue Timeout::Error => e
            FFMPEG.logger.error "Process hung...\n@command\n#{command}\nOutput\n#{@output}\n"
            raise Error, "Process hung. Full output: #{@output}"
          end
        end
      end
  end
end
