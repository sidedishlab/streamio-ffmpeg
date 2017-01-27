Streamio FFMPEG
[fork](https://github.com/streamio/streamio-ffmpeg)

===============

you can get the FFMPEG from 
[here](https://github.com/FFmpeg/FFmpeg)

## Installation (Gemfile)

```bash
gem 'streamio-ffmpeg', github: 'sidedishlab/streamio-ffmpeg'
```

## Animation GIF

initialize

```ruby
movie = FFMPEG::Movie.new("path/to/movie.mp4")
or
movie = FFMPEG::Movie.new("http://domain/path/to/movie.mp4")
```

options for example

```ruby
options = {
  seek_time: '04:08',
  duration: 5,
}

animate_options = {
  input_options: {
    fps: 10,
    scale: '480:-1:flags=lanczos',
  }
}

movie.animate("path/to/movie.gif", options, animate_options)
```

use palette

```ruby
movie.animate(output, options, animate_options, true)
```

if defined rmagick then make high quality animation.

```ruby
movie.animate2(output, options, animate_options, true)
```


## Segment for Http Live Streaming(HLS)

First argument is the output playlist file path.
Second argument is the output file path.

initialize

```ruby
movie = FFMPEG::Movie.new("path/to/movie.mp4")
or
movie = FFMPEG::Movie.new("http://domain/path/to/movie.mp4")
```

options for example

```ruby
options = {
  audio_codec: 'copy',
  video_codec: 'copy',
  vbsf: 'h264_mp4toannexb',
  map: 0,
  format: 'mpegts',
  time: 30,
  list_flags: '-cache'
}

movie.segment("tmp/playlists/playlist.m3u8", "tmp/streams/stream_%d.ts", options)
```

Keep track of progress with an optional block.

``` ruby
movie.segment("tmp/playlists/playlist.m3u8", "tmp/streams/stream_%d.ts", options) do |progress|
  puts progress # 0.2 ... 0.5 ... 1.0
end
```
