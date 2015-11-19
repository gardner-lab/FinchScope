function [audio_ts, audio, video_ts, video] = extractmedia(fl)
  % extractmedia.m

  % function to assit parsing data from FreedomScopes
  %   Created: 2015/09/20
  %   By: Nathan Perkins





% get path
[folder, ~, ~] = fileparts(mfilename('fullpath'));

% random seed
tmp_rnd = int2str(round(rand * 99999));

% get exec
cmd = ['"' folder filesep 'extractmedia" -m "' fl '" > "' folder filesep 'tmp' tmp_rnd '.csv"'];
[o, c] = system(cmd);

% check for error
if 0 < o
    error('Unable to read aduio: %s.', c);
end

% read csv file
m = csvread([folder filesep 'tmp' tmp_rnd '.csv']);
delete([folder filesep 'tmp' tmp_rnd '.csv']);

% get outputs
outputs = unique(m(:, 1));
if 2 ~= length(outputs)
    error('Unexpected number of outputs.');
end

% get types
types = unique(m(:, 2));
if 2 ~= length(types)
    error('Unexpected output types.');
end

% audio
audio_ts = m(m(:, 2) == 1, 3);
audio_ts(audio_ts < 0) = nan;
audio = m(m(:, 2) == 1, 4);

% video
video_ts = m(m(:, 2) == 2, 3);

% read video
video = {};
vh = VideoReader(fl);
while hasFrame(vh)
    video{end + 1} = readFrame(vh);
end

if length(video_ts) ~= length(video)
    warn('Unexpected frame count.');
end

end
