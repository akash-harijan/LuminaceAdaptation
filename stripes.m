

clear all;
clc;

width = 10;
strips = zeros(200,255*width, "double");

for i = 1:255
    strips(:,((i-1)*width)+1:i*width) = i*4;
end


strips_10 = zeros(200,1023*width, "double");

for i = 1:1023
    strips_10(:,((i-1)*width)+1:i*width) = i;%*power(2,6);
end




screenid = max(Screen('Screens'))-1;

[d_width, d_height] = Screen('WindowSize', screenid);
xcenter = d_width/2;
ycenter = d_height/2;


img = ones(d_height, d_width, 'double') * 128;

[strips_h ,strips_w] = size(strips);

gap_1 = 400;

img(ycenter-strips_h/2+1-gap_1: ycenter+strips_h/2-gap_1, xcenter-strips_w/2+1:xcenter+strips_w/2) = strips;


strips_10 = imresize(strips_10, [strips_h ,strips_w]);

[strips_10_h ,strips_10_w] = size(strips_10);

img(ycenter-strips_10_h/2+1+gap_1: ycenter+strips_10_h/2+gap_1, xcenter-strips_10_w/2+1:xcenter+strips_10_w/2) = strips_10;


canary = onCleanup(@sca);

PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'EnableHDR', 'Nits', 'HDR10');
win = PsychImaging('OpenWindow', screenid, 0);

% [~, img] = ConvertRGBSourceToRGBTargetColorSpace(info.ColorGamut, win, img);

[maxFALL, maxCLL] = ComputeHDRStaticMetadataType1ContentLightLevels(img);
PsychHDR('HDRMetadata', win, 0, maxFALL, maxCLL);

texid = Screen('MakeTexture', win, img);

while ~KbCheck

    Screen('DrawTexture', win, texid);
    Screen('Flip', win);
    
end

Screen('Close');
sca;
