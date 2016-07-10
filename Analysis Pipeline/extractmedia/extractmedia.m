function [audio_ts, audio, video_ts, video] = extractmedia(fl, time_start, time_stop)

% default to empty
if ~exist('time_start', 'var')
    time_start = [];
end
if ~exist('time_stop', 'var')
    time_stop = [];
end

% use mex file to extract time stamps and aligned audio
info = extractaudio(fl);
audio_ts = info.audio_t;
audio = info.audio;
video_ts = info.video_t;
clear info;

% clip by time
o_video_ts = video_ts;
if ~isempty(time_start)
    audio = audio(audio_ts >= time_start, :);
    audio_ts = audio_ts(audio_ts >= time_start);
    video_ts = video_ts(video_ts >= time_start);
end
if ~isempty(time_stop)
    audio = audio(audio_ts < time_stop, :);
    audio_ts = audio_ts(audio_ts < time_stop);
    video_ts = video_ts(video_ts < time_stop);
end

% read video
video = cell(length(video_ts), 1);
frm_out = 1;
frm_in = 0; % input 
vh = VideoReader(fl);
while hasFrame(vh)
    % read frame
    f = readFrame(vh);
    frm_in = frm_in + 1;
    
    % stop at frame
    if ~isempty(time_start) && o_video_ts(frm_in) < time_start
        continue;
    end
    if ~isempty(time_stop) && o_video_ts(frm_in) >= time_stop
        break;
    end
    
    % read frame
    video{frm_out} = f;
    frm_out = frm_out + 1;
end

% sanity check some details
if length(video_ts) ~= length(video)
    warning('Unexpected frame count.');
end

end

