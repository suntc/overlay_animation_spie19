function [] = fromTxtFile(filename1, filename2)

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

% read lifetime data also from text file
% write into one object
% -lt {4x1cell}: {[Nx1 double], [Nx1 double], [Nx1 double], [Nx1 double]}
% -int {4x1cell}: {[Nx1 double], [Nx1 double], [Nx1 double], [Nx1 double]}
% -snr {4x1cell}: {[Nx1 double], [Nx1 double], [Nx1 double], [Nx1 double]}
ltData = {};
ltData.lt = {};
ltData.lt{1, 1} = txtdata{1, 2};
ltData.lt{1, 2} = txtdata{1, 3};
ltData.lt{1, 3} = txtdata{1, 4};
ltData.lt{1, 4} = txtdata{1, 5};

% process
process(v, posData, ltData);

end