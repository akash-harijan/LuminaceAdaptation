
clear all;
clc;

screenid = max(Screen('Screens'))-1;
[d_width, d_height] = Screen('WindowSize', screenid);


%%

canary = onCleanup(@sca);

PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'EnableHDR', 'Nits', 'HDR10');
win = PsychImaging('OpenWindow', screenid, 0);
% HideCursor(win);
    


file_id=fopen('state.txt','r');
var_vals = fscanf(file_id,'%f');
fclose(file_id);

% var_vals = [200, 100, 1000, 500, 200, 30, 40, 10];

stimulusLuma = var_vals(1);
backLuma = var_vals(2);
surrLumaInt = var_vals(3);
surrColor = var_vals(4);
bg_r = var_vals(5); 
st_r=var_vals(6); 
c_width = var_vals(7);
c_height = var_vals(8);
marginLuma = var_vals(9);
marginRadius = var_vals(10);


marginIdx = 1;
marginlists = [0.01, 0.1, 0.5, 1, 10, 20, 50, 100, 500];

% surrColorIdx = 1;
% surrColor = [1023 1023 1023; 1023 0 0; 0 1023 0; 0 0 1023 ];


x_c=0;y_c=0;
[y,x]=ndgrid(-bg_r:bg_r,-bg_r:bg_r);

background_c = (x-x_c).^2+(y-y_c).^2 >= (bg_r)^2;
% unique(background_c)

background = double(background_c);
background(background_c==0) = backLuma;
background(background_c==1) = surrLumaInt;

[maxFALL, maxCLL] = ComputeHDRStaticMetadataType1ContentLightLevels(background);
PsychHDR('HDRMetadata', win, 0, maxFALL, maxCLL);



KbName('UnifyKeyNames');
activeKeys = [KbName('LeftArrow'), KbName('RightArrow'), KbName('UpArrow'), KbName('DownArrow'), KbName('escape')];


keyFlags = zeros(1,256); % an array of zeros
keyFlags(activeKeys) = 1;
dvc = GetKeyboardIndices;
KbQueueCreate(dvc, keyFlags); % initialize the Queue

EXIT_SIGNAL = 0;
KEY_IDX = 1;

surrLuma = [0 0 0];
while ~EXIT_SIGNAL
%     disp("In Main Loop");
    KbQueueStart;% start keyboard monitoring
    
%     img(ref_img==255)=backLuma;
%     img(~ref_img)=stimulusLuma;
%     


    stimulusLuma = var_vals(1);
    backLuma = var_vals(2);
    surrLumaInt = var_vals(3);
    surrColor = int8(var_vals(4));
    bg_r = int16(60*0.69*5); %pix_per_cm * cms * degree
    st_r = int16(60*0.69*1); 
    c_width = 15;
    c_height = 15;
    marginLuma = var_vals(9);
    marginRadius = var_vals(10);

    surrLuma = [surrLumaInt surrLumaInt surrLumaInt];
%     disp(surrColor)
    if surrColor == 1
        surrLuma = [surrLumaInt surrLumaInt surrLumaInt];
    elseif surrColor == 2
        surrLuma = [surrLumaInt 0 0];
    elseif surrColor == 3
        surrLuma = [0 surrLumaInt 0];
    elseif surrColor == 4
        surrLuma = [0 0 surrLumaInt];
    end
    
    
    
    x_c=0;y_c=0;
    [y,x]=ndgrid(-bg_r:bg_r,-bg_r:bg_r);
    
    background_c = (x-x_c).^2+(y-y_c).^2 >= (bg_r-10)^2;
%     unique(background_c)
    
    background = double(background_c);
    background(background_c==0) = backLuma;
    background = cat(3, background, background, background);

    temp_1 = background(:,:,1);
    temp_2 = background(:,:,2);
    temp_3 = background(:,:,3);
    temp_1(background_c==1) = surrLuma(1);
    temp_2(background_c==1) = surrLuma(2);
    temp_3(background_c==1) = surrLuma(3);
    background = cat(3, temp_1, temp_2, temp_3);

%     unique(background)
    

%     background = medfilt2(background, [5, 5]); % try smooth here

     background = imgaussfilt(background, 2); % try smooth here


    x_c=0;y_c=0;
    
    [y,x]=ndgrid(-st_r:st_r,-st_r:st_r);
    circle_1_c = (x-x_c).^2+(y-y_c).^2 >= st_r^2;
    circle_1 = double(circle_1_c);
    circle_1(circle_1_c==0) = stimulusLuma;
    circle_1(circle_1_c==1) = backLuma;
    
    [y,x]=ndgrid(-st_r+c_width:st_r-c_width,-st_r+c_width:st_r-c_width);
    circle_2_idx = (x-x_c).^2+(y-y_c).^2 <= (st_r-c_width)^2;
    circle_2 = double(circle_2_idx);
    circle_2(circle_2_idx) = backLuma;
    circle_2(~circle_2_idx) = stimulusLuma;
    
    background(bg_r-st_r:bg_r+st_r, bg_r-st_r:bg_r+st_r,:) = cat(3,circle_1,circle_1,circle_1); 
    background(bg_r-st_r+c_width:bg_r+st_r-c_width, bg_r-st_r+c_width:bg_r+st_r-c_width,:) = cat(3, circle_2,circle_2,circle_2);
    
    no_of_gaps = randi([0,2],1,1);
    if no_of_gaps==1
        rand_no = randi([1,4],1,1);

        if rand_no==1
            rect = double(ones(c_height, st_r)) * backLuma;
            background(bg_r-c_height/2:bg_r+c_height/2-1, bg_r:bg_r+st_r-1,:) = cat(3, rect, rect,rect);
        elseif rand_no==2
            rect = double(ones(c_height, st_r)) * backLuma;
            background(bg_r-c_height/2:bg_r+c_height/2-1, bg_r-st_r+1:bg_r,:) = cat(3, rect, rect,rect);
        elseif rand_no==3
            rect = double(ones(st_r, c_height)) * backLuma;
            background(bg_r-st_r+1:bg_r, bg_r-c_height/2:bg_r+c_height/2-1,:) = cat(3, rect, rect,rect);
        elseif rand_no==4
            rect = double(ones(st_r, c_height)) * backLuma;
            background(bg_r:bg_r+st_r-1, bg_r-c_height/2:bg_r+c_height/2-1,:) = cat(3, rect, rect,rect); 
        end

    elseif no_of_gaps==2
        rand_no = randi([1,4],1,1);
        rand_no2 = randi([1,4],1,1);

        if rand_no==1
            rect = double(ones(c_height, st_r)) * backLuma;
            background(bg_r-c_height/2:bg_r+c_height/2-1, bg_r:bg_r+st_r-1,:) = cat(3, rect, rect,rect);
        elseif rand_no==2
            rect = double(ones(c_height, st_r)) * backLuma;
            background(bg_r-c_height/2:bg_r+c_height/2-1, bg_r-st_r+1:bg_r,:) = cat(3, rect, rect,rect);
        elseif rand_no==3
            rect = double(ones(st_r, c_height)) * backLuma;
            background(bg_r-st_r+1:bg_r, bg_r-c_height/2:bg_r+c_height/2-1,:) = cat(3, rect, rect,rect);
        elseif rand_no==4
            rect = double(ones(st_r, c_height)) * backLuma;
            background(bg_r:bg_r+st_r-1, bg_r-c_height/2:bg_r+c_height/2-1,:) = cat(3, rect, rect,rect);         
        end

        if rand_no2==1
            rect = double(ones(c_height, st_r)) * backLuma;
            background(bg_r-c_height/2:bg_r+c_height/2-1, bg_r:bg_r+st_r-1,:) = cat(3, rect, rect,rect);
        elseif rand_no2==2
            rect = double(ones(c_height, st_r)) * backLuma;
            background(bg_r-c_height/2:bg_r+c_height/2-1, bg_r-st_r+1:bg_r,:) = cat(3, rect, rect,rect);
        elseif rand_no2==3
            rect = double(ones(st_r, c_height)) * backLuma;
            background(bg_r-st_r+1:bg_r, bg_r-c_height/2:bg_r+c_height/2-1,:) = cat(3, rect, rect,rect);
        elseif rand_no2==4
            rect = double(ones(st_r, c_height)) * backLuma;
            background(bg_r:bg_r+st_r-1, bg_r-c_height/2:bg_r+c_height/2-1,:) = cat(3, rect, rect,rect);           
        end

    end


    background_c2 = background_c;
    background_c2(bg_r-st_r:bg_r+st_r, bg_r-st_r:bg_r+st_r) = (~background_c2(bg_r-st_r:bg_r+st_r, bg_r-st_r:bg_r+st_r)) .* circle_1_c;
%     background(background_c2) = backLuma;
%     background(background_c==1) = surrLuma;

    background(background_c2) = backLuma;
    temp_1 = background(:,:,1);
    temp_2 = background(:,:,2);
    temp_3 = background(:,:,3);
    temp_1(background_c==1) = surrLuma(1);
    temp_2(background_c==1) = surrLuma(2);
    temp_3(background_c==1) = surrLuma(3);
    background = cat(3, temp_1, temp_2, temp_3);

%     background = imgaussfilt(background, 2); % try smooth here


%     background=imgaussfilt(background);

%     windowWidth = 9; % Some odd number.
%     kernel = ones(3, windowWidth) / windowWidth;
%     background = conv(background, kernel, 'same');
%     w = 3;
%     H  = ones(w,w);                      % The 2D averaging filter
%     background  = filter2(H,background,'same');

%     background = medfilt2(background, [5, 5]);

    Screen('FillRect', win, surrLuma);
    texid = Screen('MakeTexture', win, background);
    Screen('DrawTexture', win, texid);

    % And some text, 30 pixels high, centered, in a 200 nits green:
    Screen('TextSize', win, 30);



    text = {['Stimulus Luminace : ', num2str(stimulusLuma,'%.2f')],
    ['Background Stimulus : ', num2str(backLuma,'%.2f')],
    ['Surrounding Luminance : ', num2str(surrLumaInt,'%.2f')],
    ['Surrounding Color : ', num2str(surrColor,'%.2f')],
    ['Background Radius: ', num2str(bg_r,'%.2f')],
    ['Circle 1 Radius: ', num2str(st_r,'%.2f')],
    ['Circle 2 Gap: ', num2str(c_width,'%.2f')],
    ['Gap: ', num2str(c_height,'%.2f')],
    ['Margin Luminance : ', num2str(marginLuma,'%.2f')],
    ['Margin Radius : ', num2str(marginRadius,'%.2f')]
    };


    text{KEY_IDX} = ['<<', text{KEY_IDX}, '>>'];
%      text{KEY_IDX} = [text{KEY_IDX}, '<<---'];
    text = strjoin(text, '\n');


%     text = sprintf('Stimulus Luminance : %d\nBackground Luminance : %d\nSurrounding Luminance : %d\nBackground Radius: %d\nCircle 1 Radius: %d\nCircle 2 Gap: %d\nGap: %d\nMargin Luminance : %d', ...
%         stimulusLuma, backLuma, surrLuma, bg_r, st_r, c_width, c_height, marginLuma);

    DrawFormattedText(win, text, 'left', 100, [0 200 0]);


    Screen('Flip', win);

    KbWait([],2); % press any key to start the movement

    KbQueueStop;
    [pressed, firstPress, firstRelease, lastPress, lastRelease]=KbQueueCheck;% check if space was pressed
    if pressed
        keyName = KbName(find(firstPress));


        if strcmp(keyName, 'UpArrow')
            KEY_IDX = KEY_IDX - 1; 
            if KEY_IDX<1 KEY_IDX=1, end
        elseif strcmp(keyName, 'DownArrow')
            KEY_IDX = KEY_IDX + 1; 
            if KEY_IDX>10 KEY_IDX=10, end

        elseif strcmp(keyName, 'LeftArrow')
            if KEY_IDX == 9
%                 var_vals(8) = var_vals(8) - 0.5;
                marginIdx = marginIdx - 1;
                if marginIdx < 1
                    marginIdx = 1;
                end
                var_vals(9) = marginlists(marginIdx);
            elseif KEY_IDX == 10
                var_vals(10) = var_vals(10) - 1;
            elseif KEY_IDX == 4
                surrColor = surrColor - 1;
                if surrColor < 1
                    surrColor = 1;
                end
                var_vals(KEY_IDX) = surrColor;

%                 var_vals(3) = surrColor(surrColorIdx, 1);
%                 var_vals(4) = surrColor(surrColorIdx, 2);
%                 var_vals(5) = surrColor(surrColorIdx, 3);

            elseif KEY_IDX>=1 && KEY_IDX<=3
                var_vals(KEY_IDX) = var_vals(KEY_IDX) - var_vals(9);
            elseif KEY_IDX>=5 && KEY_IDX<=8
                var_vals(KEY_IDX) = var_vals(KEY_IDX) - var_vals(10);
            end
        elseif strcmp(keyName, 'RightArrow')
            if KEY_IDX == 9
%                 var_vals(8) = var_vals(8) + 0.5; 

                marginIdx = marginIdx + 1;
                if marginIdx > length(marginlists)
                    marginIdx = 9;
                end
                var_vals(KEY_IDX) = marginlists(marginIdx);

            elseif KEY_IDX == 10
                var_vals(KEY_IDX) = var_vals(KEY_IDX) + 1; 
            elseif KEY_IDX == 4
                surrColor = surrColor + 1;
                if surrColor > 4
                    surrColor = 4;
                end
                var_vals(KEY_IDX) = surrColor;
%                 var_vals(3) = surrColor(surrColorIdx, 1);
%                 var_vals(4) = surrColor(surrColorIdx, 2);
%                 var_vals(5) = surrColor(surrColorIdx, 3);

            elseif KEY_IDX>=1 && KEY_IDX<=3
                var_vals(KEY_IDX) = var_vals(KEY_IDX) + var_vals(9);
            elseif KEY_IDX>=5 && KEY_IDX<=8
                var_vals(KEY_IDX) = var_vals(KEY_IDX) + var_vals(10);
            end
        elseif strcmp(keyName, 'ESCAPE')%if escape was pressed
            EXIT_SIGNAL = 1;
            KbQueueRelease;
            sca;
        end
        Screen('Close');
    end
end

file_id=fopen('state.txt','w');
fprintf(file_id,'%.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f\n', var_vals);
fclose(file_id);

Screen('CloseAll');
sca;


%%

% a = [];
% a = [a, 5];
% a = [a, 6]
% disp(a)






%% GRAY to COLOR

% background = double(background_c);
% background = cat(3, background, background, background);
% 
% background(background_c==0) = backLuma;
% background(background_c==1) = surrLuma;
% unique(background)
% 
% imshow(background)





%% FILE READ and WRITE


% var_vals = [1150, 0, 1023, 1023, 1023, 440, 60, 20, 20, 20, 10];
% var_vals = [200, 100, 1000, 500, 200, 30, 40, 10];
% 
% file_id=fopen('state.txt','w');
% fprintf(file_id,'%.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f \n', var_vals);
% fclose(file_id);
% 
% 
% 
% file_id=fopen('state.txt','r');
% vals = fscanf(file_id,'%f');
% fclose(file_id);
% 
% disp(vals)




%% TESTING STRING

% text = sprintf('Stimulus Luminace : %d\nBackground Stimulus : %d\nSurrounding Luminance : %d\nBackground Radius: %d\nCircle 1 Radius: %d\nCircle 2 Gap: %d\nGap: %d\nMargin Luminance : %d', ...
%         stimulusLuma, backLuma, surrLuma, bg_r, st_r, c_width, c_height, marginLuma);

% stimulusLuma = 200;
% backLuma = 100;
% surrLuma = 1023;
% bg_r = 500; 
% st_r=200; 
% c_width = 30;
% c_height = 40;
% marginLuma = 1;
% 
% text = {['Stimulus Luminace : ', num2str(stimulusLuma,'%.2f')],
%     ['Background Stimulus : ', num2str(backLuma,'%.2f')],
%     ['Surrounding Luminance : ', num2str(surrLuma,'%.2f')],
%     ['Background Radius: ', num2str(bg_r,'%.2f')],
%     ['Circle 1 Radius: ', num2str(st_r,'%.2f')],
%     ['Circle 2 Gap: ', num2str(c_width,'%.2f')],
%     ['Gap: ', num2str(c_height,'%.2f')],
%     ['Margin Luminance : ', num2str(marginLuma,'%.2f')]};
% 
% 
% 
% text{1} = ['\bf\color{red} ', text{1}, ' \rm\color{black}'];
% text = strjoin(text, '\n');



%% Testing VISCIRCLES

% cir1 = viscircles([0,0], 100, 'color', 'r');
% xd = cir1.Children(1).XData(1:end-1); %leave out the nan
% yd = cir1.Chidren(1).YData(1:end-1);
% fill(xd, yd, 'r');
% 
% imshow(cir1);



%%

% while ~timeout
% 
% 
%     img(ref_img==255)=backLuma;
%     img(~ref_img)=stimulusLuma;
% 
% 
%     texid = Screen('MakeTexture', win, img);
%     Screen('DrawTexture', win, texid);
% 
%     % And some text, 30 pixels high, centered, in a 200 nits green:
%     Screen('TextSize', win, 30);
%     text = sprintf('Stimulus Luminace : %d\nBackground Stimulus : %d\nSurrounding Luminance : %d', stimulusLuma, backLuma, surrLuma);
%     DrawFormattedText(win, text, 'left', 100, [0 200 0]);
% 
% 
%     Screen('Flip', win);
%         
%     while true
% 
%         [keyIsDown, keyTime, keyCode] = KbCheck;
%         
%         if (keyIsDown), break; end
% 
% 
%     end
% 
%     keyName = KbName(keyCode);
% %     disp(keyName);
%     if strcmpi(keyName, 'rightarrow')
%         stimulusLuma = stimulusLuma + 100;
%     elseif strcmpi(keyName, 'leftarrow')
%         stimulusLuma = stimulusLuma - 100;
%     elseif strcmpi(keyName, 'escape')
%         break
%     end
%     keyIsDown = 0;
% 
% %     disp(keyTime);
% %     disp(keyCode);
% 
% %     timeout = true;
% 
% 
% end

% RestrictKeysForKbCheck;
% ListenChar(1);




%% Testing

%sprintf('Stimulus Luminace : %d\nBackground Stimulus : %d\nSurrounding Luminance : %d', 100, 200, 300)

% 
% fresh_img = im2gray(double(imread('C-.png')));
% unique(fresh_img)


%% Vectorized C

% clear all;
% 
% screenid = max(Screen('Screens'));
% [d_width, d_height] = Screen('WindowSize', screenid);
% xcenter = d_width/2;
% ycenter = d_height/2;
% 
% %define radius and center coordinates
% r=200;x_c=0;y_c=0;
% 
% %generate a coordinate grid
% [y,x]=ndgrid(-ycenter:ycenter,-xcenter:xcenter);
% %perform calculation
% 
% paper= (x-x_c).^2+(y-y_c).^2 <= r^2;
% %show result
% imshow(paper)




%%










% C = im2gray(imread('C-removebg-preview.png'));

% C = im2gray(imread('C.png'));
% C(C>128)=255;
% C(C<=128)=0;
% imwrite(C, 'C-.png');

% while ~KbCheck
% 
%     Screen('DrawTexture', win, texid);
%     Screen('Flip', win);
%     
% end



% img = ones(1024,1024, 'uint8')*128;
% imshow(img);
% 
% circleout = circle(3, 4, 2, 'g') ;
% 
% figure
% imshow(circleout);
% 
% % figure
% % img2 = ones(1024,1024, 'uint8')*255;
% % imshow(img2);
% 
% 
% function circles = circle(x,y,r,c)
% hold on
% th = 0:pi/50:2*pi;
% x_circle = r * cos(th) + x;
% y_circle = r * sin(th) + y;
% circles = plot(x_circle, y_circle);
% fill(x_circle, y_circle, c)
% hold off
% axis equal
% end


%%

% clear all;
% clc;
% 
% stimulusLuma = 128;
% backLuma = 0;
% surrLuma = 255;
% marginLuma = 1;
% 
% bg_r = 500; st_r=200; c_width = 30;c_height = 40;
% 
% 
% 
% x_c=0;y_c=0;
% [y,x]=ndgrid(-bg_r:bg_r,-bg_r:bg_r);
% 
% background_c = (x-x_c).^2+(y-y_c).^2 >= bg_r^2;
% unique(background_c)
% 
% background = double(background_c);
% background(background_c==0) = backLuma;
% background(background_c==1) = surrLuma;
% unique(background)
% 
% x_c=0;y_c=0;
% 
% [y,x]=ndgrid(-st_r:st_r,-st_r:st_r);
% circle_1_c = (x-x_c).^2+(y-y_c).^2 >= st_r^2;
% circle_1 = double(circle_1_c);
% circle_1(circle_1_c==0) = stimulusLuma;
% circle_1(circle_1_c==1) = backLuma;
% 
% [y,x]=ndgrid(-st_r+c_width:st_r-c_width,-st_r+c_width:st_r-c_width);
% circle_2 = double((x-x_c).^2+(y-y_c).^2 <= (st_r-c_width)^2);
% circle_2(circle_2==0) = stimulusLuma;
% circle_2(circle_2==1) = backLuma;
% 
% background(bg_r-st_r:bg_r+st_r, bg_r-st_r:bg_r+st_r) = circle_1; 
% background(bg_r-st_r+c_width:bg_r+st_r-c_width, bg_r-st_r+c_width:bg_r+st_r-c_width) = circle_2;
% 
% rect = double(ones(c_height, st_r)) * backLuma;
% background(bg_r-c_height/2:bg_r+c_height/2-1, bg_r:bg_r+st_r-1) = rect;
% 
% background_c2 = background_c;
% background_c2(bg_r-st_r:bg_r+st_r, bg_r-st_r:bg_r+st_r) = (~background_c2(bg_r-st_r:bg_r+st_r, bg_r-st_r:bg_r+st_r)) .* circle_1_c;
% background(background_c2) = backLuma;
% background(background_c==1) = surrLuma;
% 
% 
% 
% imshow(int8(background))


% 
% % paper = double(paper);
% % paper(paper==0) = 2;
% 
% disp('Paper : ')
% unique(paper)
% 
% imshow(paper);
% figure
% imshow(paper2)


%%