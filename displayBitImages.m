

eight_bit = ones(512,512,3,'double')*255;
nine_bit = ones(512,512,3,'double')*511;
ten_bit = ones(512,512,3,'double')*1023;
elev_bit = ones(512,512,3,'double')*2047;
twelv_bit = ones(512,512,3,'double')*4095;

img = twelv_bit;



screenid = max(Screen('Screens'));

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


sca;

%%

% imgfilename = '2224x860/2224x860/A001C003_190123_R23H.1422869.exr';
% imgfilename='C:\Users\3D-Processing\AppData\Roaming\MathWorks\MATLAB Add-Ons\Collections\Psychtoolbox-3\Psychtoolbox\PsychDemos\OpenEXRImages\Desk.exr';



% imgfilename='C:\Users\3D-Processing\AppData\Roaming\MathWorks\MATLAB Add-Ons\Collections\Psychtoolbox-3\Psychtoolbox\PsychDemos\OpenEXRImages\Ocean.exr';
% [img, info, errmsg] = HDRRead(imgfilename, 1);



%%

eight_bit = ones(512,512,3,'double')*1023;
imshow(eight_bit)

figure
eight_bit = ones(512,512,3,'double')*255;
imshow(eight_bit)




%%
