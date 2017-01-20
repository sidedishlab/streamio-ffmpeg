module FFMPEG
  class SegmentOptions < Hash
    def initialize(options = {})
      merge!(options)
    end

    def params_order(k)
      if k =~ /codec$/
        0
      elsif k =~ /vbsf/
        1
      elsif k =~ /map/
        2
      else
        3
      end
    end

    def to_a
      params = []

      # codecs should go before the presets so that the files will be matched successfully
      # all other parameters go after so that we can override whatever is in the preset
      keys.sort_by{|k| params_order(k) }.each do |key|
        value   = self[key]
        a = send("segment_#{key}", value) if value && supports_option?(key)
        params += a unless a.nil?
      end
      params.map(&:to_s)
    end

    private

      # メソッドの存在確認
      def supports_option?(option)
        private_methods.include? "segment_#{option}".to_sym
      end

      # ex: -vcodec copy
      def segment_video_codec(value)
        ['-vcodec', value]
      end

      # ex: -acodec copy
      def segment_audio_codec(value)
        ['-acodec', value]
      end

      # ex: -vbsf h264_mp4toannexb
      def segment_vbsf(value)
        ['-vbsf', value]
      end

      # ex: -map 0
      def segment_map(value)
        ['-map', value]
      end

      # ex: -segment_format mpegts
      def segment_format(value)
        ['-segment_format', value]
      end

      # ex: -segment_format_options movflags=+faststart
      def segment_format_options(value)
        ['-segment_format_options', value]
      end

      # ex: -segment_list playlist.m3u8
      def segment_list(value)
        ['-segment_list', value]
      end

      # ex: -segment_list_flags -cache
      def segment_list_flags(value)
        ['-segment_list_flags', value]
      end

      # ex: -segment_list_size 0 – INT_MAX
      def segment_list_size(value)
        ['-segment_list_size', value]
      end

      # ex: -segment_list_type 
      # -1, flat
      #  0, csv
      #  1, ext
      #  2, ffconcat
      #  3, m3u8
      #  4, hls
      #
      def segment_list_type(value)
        ['-segment_list_type', value]
      end

      # ex: -force_key_frames 1,2,3,5,8,13,21
      def segment_force_key_frames(value)
        ['-force_key_frames', value.is_a?(Array) ? value.join(',') : value]
      end

      # ex: -segment_frames 100,200,300,500,800
      def segment_frames(value)
        ['-segment_frames', value.is_a?(Array) ? value.join(',') : value]
      end

      # ex: -segment_time 5
      def segment_time(value)
        ['-segment_time', value]
      end

      # ex: -segment_times 1,2,3,5,8,13,21
      def segment_times(value)
        ['-segment_times', value.is_a?(Array) ? value.join(',') : value]
      end

      # ex: -segment_atclocktime 0|1
      def segment_atclocktime(value)
        ['-segment_atclocktime', value.zero?? 0 : 1]
      end

      # ex: -segment_clocktime_offset 300
      def segment_clocktime_offset(value)
        ['-segment_clocktime_offset', value]
      end

      # ex: -segment_clocktime_wrap_duration
      def segment_clocktime_wrap_duration(value)
        ['-segment_clocktime_wrap_duration', value]
      end

      # ex: -segment_time_delta 0.05
      def segment_time_delta(value)
        ['-segment_time_delta', value]
      end

      # ex: -segment_wrap 0 – INT_MAX
      def segment_wrap(value)
        ['-segment_wrap', value]
      end

      # ex: -segment_start_number 0 – I64_MAX
      def segment_start_number(value)
        ['-segment_start_number', value]
      end

      # ex: -reset_timestamps 0|1
      def segment_reset_timestamps(value)
        ['-reset_timestamps', value.zero?? 0 : 1]
      end

      # ex: -write_empty_segments 0|1
      def segment_write_empty_segments(value)
        ['-write_empty_segments', value.zero?? 0 : 1]
      end
  end
end
