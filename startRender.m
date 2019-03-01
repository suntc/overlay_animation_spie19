function [] = startRender(filename1, filename2, filename3)

% read video data
v = VideoReader( filename1 );

% read segmentation position from text file
% write into one object
% -px [Nx1]
% -py [Nx1]
% -frames [integer N]
txtFile = fopen(filename2);
formatSpec = '%u %f %f %f %f %f %f %f %f %f %s %s';
posData = {};
txtdata = textscan(txtFile, formatSpec);
posData.px = txtdata{1, 6};
posData.py = txtdata{1, 7};
posData.frames = size(txtdata{1, 1}, 1);
posData.radius = txtdata{1, 8};
% align dimensions of segmentation positions with video
% It seems that the txtfile has same dimension with video frame
% number; awaiting confirmation

assert(v.NumberOfFrames == posData.frames);

% read from mat file

mat_data = load( filename3 );
lt  = mat_data.lifet_avg;
snr = mat_data.SNR;

% read lifetime data also from text file
% write into one object
% -lt {4x1cell}: {[Nx1 double], [Nx1 double], [Nx1 double], [Nx1 double]}
% -int {4x1cell}: {[Nx1 double], [Nx1 double], [Nx1 double], [Nx1 double]}
% -snr {4x1cell}: {[Nx1 double], [Nx1 double], [Nx1 double], [Nx1 double]}
ltData = {};
ltData.lt = {};
ltData.snr = {};
t = 1: (length(lt{1})-1)/(posData.frames-1) :length(lt{1});
for i = 1: 4
    % use lifetime values from text file
    %ltData.lt{1, 1} = txtdata{1, i};
    % use lifetime values from mat file
    ltData.lt{1, i} = interp1(1:length(lt{i}), lt{i}, t)';
    ltData.snr{1, i} = interp1(1:length(lt{i}), snr{i}, t)';
end

% process
process(v, posData, ltData);

end