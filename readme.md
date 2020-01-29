## example
% Inputs
points: [N x 2]
values: [N x 1]
vf: [720 x 1280 x 3] (for example)

% Paramters to be adjusted
WeightFactor = 2; % power: closer points' impact
searchRadius = 20; % interpolation search radius (in pixel)
Alpha = 0.5; % overlay opacity