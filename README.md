Streamio FFMPEG
[fork](https://github.com/streamio/streamio-ffmpeg)

===============

you can get the FFMPEG from 
[here](https://github.com/FFmpeg/FFmpeg)

### Segment for Http Live Streaming(HLS)

First argument is the output playlist file path.
Second argument is the output file path.

```ruby
movie.segment("tmp/playlists/playlist.m3u8", "tmp/streams/stream_%d.ts")
```

Keep track of progress with an optional block.

``` ruby
movie.segment("tmp/objects/") { |progress| puts progress } # 0.2 ... 0.5 ... 1.0
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

movie.segment(output_dir, options)
```
