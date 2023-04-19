
clear all;

screenid = max(Screen('Screens'))-1;

[d_width, d_height] = Screen('WindowSize', screenid);
xcenter = d_width/2;
ycenter = d_height/2;

img = zeros(d_height, d_width, 'double');

canary = onCleanup(@sca);

PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'EnableHDR', 'Nits', 'HDR10');
win = PsychImaging('OpenWindow', screenid, 0);

% [~, img] = ConvertRGBSourceToRGBTargetColorSpace(info.ColorGamut, win, img);

[maxFALL, maxCLL] = ComputeHDRStaticMetadataType1ContentLightLevels(img);
PsychHDR('HDRMetadata', win, 0, maxFALL, maxCLL);


while ~KbCheck

    for val=0:1:10

        tic

        disp(val)

        img(ycenter-500:ycenter+500, xcenter-500:xcenter+500) = 495+val;

        texid = Screen('MakeTexture', win, img);
        Screen('DrawTexture', win, texid);
        Screen('Flip', win);

        a = toc;
        pause(20-a)
    end
    
end

Screen('Close');
sca;
