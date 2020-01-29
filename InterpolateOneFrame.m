function [ overlaid_vf ] = InterpolateOneFrame(points, values, vf)

%%
% points: [N x 2]
% values: [N x 1]
% vf: [720 x 1280 x 3] (for example)
%%

% Paramters to be adjusted
WeightFactor = 2; % power: closer points' impact
searchRadius = 20; % interpolation search radius (in pixel)
Alpha = 0.5; % overlay opacity

% filter out 0s
pts = [];
vs = [];
for i = 1: size(points, 1)
    if points(i, 1) ~= 0 && points(i, 2) ~= 0
        pts = [pts; points(i,:)];
        vs = [vs; values(i)];
    end
end

tree = KDTreeSearcher(pts, 'BucketSize', 20);
height = size(vf, 1);
width = size(vf, 2);

interpolatedFlimMap = zeros(height, width);

ColorLevels = 12800;
LowerBound = 1;
UpperBound = 3;
cmap = jet(ColorLevels);

function [ color ] = GetRGBColor(v)
    if v < LowerBound
        color = cmap(1, :);
        return;
    end
    if v > UpperBound
        color = cmap(ColorLevels, :);
        return;
    end
    level = round((v - LowerBound) / (UpperBound - LowerBound) * ColorLevels);
    color = cmap(level + 1, :);
    return;
end

function [ r ] = GetRChannel(v)
    if v < LowerBound
        r = cmap(1, 1);
        return;
    end
    if v > UpperBound
        r = cmap(ColorLevels, 1);
        return;
    end
    level = round((v - LowerBound) / (UpperBound - LowerBound) * ColorLevels);
    r = cmap(level + 1, 1);
    return;
end

function [ g ] = GetGChannel(v)
    if v < LowerBound
        g = cmap(1, 2);
        return;
    end
    if v > UpperBound
        g = cmap(ColorLevels, 2);
        return;
    end
    level = round((v - LowerBound) / (UpperBound - LowerBound) * ColorLevels);
    g = cmap(level + 1, 2);
    return;
end

function [ b ] = GetBChannel(v)
    if v < LowerBound
        b = cmap(1, 3);
        return;
    end
    if v > UpperBound
        b = cmap(ColorLevels, 3);
        return;
    end
    level = round((v - LowerBound) / (UpperBound - LowerBound) * ColorLevels);
    b = cmap(level + 1, 3);
    return;
end

rs = 1: height;
cs = 1: width;
VP = IDW(pts(:, 2), pts(:, 1), vs, cs, rs, -WeightFactor, 'fr', searchRadius);
unchangeMask = isnan(VP);
overlayMask = ~unchangeMask;

r = times(double(vf(:,:,1)), unchangeMask);
g = times(double(vf(:,:,2)), unchangeMask);
b = times(double(vf(:,:,3)), unchangeMask);
back_vf = cat(3, uint8(r), uint8(g), uint8(b));
r = times(double(vf(:,:,1)), overlayMask);
g = times(double(vf(:,:,2)), overlayMask);
b = times(double(vf(:,:,3)), overlayMask);
fore_vf = cat(3, uint8(r), uint8(g), uint8(b));
VP(isnan(VP)) = 0;
overlay_r = arrayfun(@GetRChannel, VP);
overlay_r(unchangeMask) = 0;
overlay_g = arrayfun(@GetGChannel, VP);
overlay_g(unchangeMask) = 0;
overlay_b = arrayfun(@GetBChannel, VP);
overlay_b(unchangeMask) = 0;
overlay = cat(3, overlay_r, overlay_g, overlay_b);
overlaid_vf = back_vf + uint8( (1 - Alpha) * double(fore_vf) + Alpha * 255 * overlay);
imshow(overlaid_vf);


end