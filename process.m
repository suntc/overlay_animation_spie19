function [ F ] = process( vr, posData, ltData )

% settings
rad = 25; %15; %3; %10; % radius
alpha = 0.5; % alpha value for overlay
dest_channel = 2;
% color scale
scale_from=[]; scale_to=[];
scale_from(1) = 3.5;
scale_to(1) = 5;
scale_from(2) = 3;
scale_to(2) = 6;
scale_from(3) = 2.5;
scale_to(3) = 5;

% setup video
jet_cmap =  colormap('jet');
ssx = vr.Width;
ssy = vr.Height;
for i=1:3
    overlay{i}  = uint8( zeros(ssy,ssx,3)); 
    val_field{i} = double( zeros(ssy,ssx,1)); 
    accum{i} = double( zeros(ssy,ssx,1)); 
end

% setup figure
h=figure; hold on;

set(h, 'Position', [100 100 640 300]);
set(h,'Color',[1 1 1]);

c=1;

vw = VideoWriter(['out_ch', num2str(dest_channel),'.mp4'],'MPEG-4');
open(vw);

for i = 1: posData.frames
    % get current video frame
    df1= vr.read(i);
    
    % get current segmentation position
    px = posData.px(i);
    py = posData.py(i);
    
    current_value = ltData.lt{dest_channel}(i);
    
    if px == 0 || py == 0 || isnan(current_value) || current_value == 0 % bad conditions
        continue;
    end
    if current_value<scale_from(dest_channel)
        current_value = scale_from(dest_channel);
    end
    if current_value>scale_to(dest_channel)
        current_value = scale_to(dest_channel);
    end
    
    ind1 = round((current_value-scale_from(dest_channel))/(scale_to(dest_channel)-scale_from(dest_channel))*63+1);
    [overlay{dest_channel}, val_field{dest_channel}, accum{dest_channel}] = drawCirc( [px,py], rad*0.7, rad, overlay{dest_channel}, jet_cmap(ind1,:)*254+1, val_field{dest_channel}, ind1, accum{dest_channel} );
    df1( ~(overlay{dest_channel}(:,:,:) == 0) ) = alpha*overlay{dest_channel}( ~(overlay{dest_channel}(:,:,:) == 0) ) + (1-alpha)*df1( ~(overlay{dest_channel}(:,:,:) == 0) );
    
    %set(gcf,'Visible', 'off');
    hold off; imshow(df1);
    
    colormap(h, jet);
    caxis([scale_from(dest_channel) scale_to(dest_channel)]);
    h0 = colorbar;
    ylabel(h0, ['Lifetime CH', int2str(dest_channel),' (ns)'])

    set(gca,'LooseInset',get(gca,'TightInset'))
    
    % save overlaid frame for video export
    disp(c);
    F(c) = getframe(gcf);
    %fprintf('%i\n ', i);
    writeVideo(vw, F(c));
    c=c+1;
end

% close window
close(h);

end

