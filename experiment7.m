clear all;
clc;

% rng(0,'twister');


screenid = max(Screen('Screens'))-1;
[d_width, d_height] = Screen('WindowSize', screenid);


%%

canary = onCleanup(@sca);

PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'EnableHDR', 'Nits', 'HDR10');
win = PsychImaging('OpenWindow', screenid, 0);


stimulusLuma = 0.075;
backLuma = 0;
surrLumaInt = 0;
surrColor = 1;

bg_r = int16(60*0.69*5); %pix_per_cm * cms * degree
st_r = int16(60*0.69*1); 
c_width = 15;
c_height = 15;


x_c=0;y_c=0;
[y,x]=ndgrid(-bg_r:bg_r,-bg_r:bg_r);
background_c = (x-x_c).^2+(y-y_c).^2 >= (bg_r)^2;
background = double(background_c);
background(background_c==0) = backLuma;
background(background_c==1) = surrLumaInt;

[maxFALL, maxCLL] = ComputeHDRStaticMetadataType1ContentLightLevels(background);
PsychHDR('HDRMetadata', win, 0, maxFALL, maxCLL);


KbName('UnifyKeyNames');
activeKeys = [KbName('2'), KbName('4'), KbName('8'), KbName('6'), KbName('0'), KbName('escape'), KbName('space'), KbName('-')];


keyFlags = zeros(1,256); % an array of zeros
keyFlags(activeKeys) = 1;
dvc = GetKeyboardIndices;
KbQueueCreate(dvc, keyFlags); % initialize the Queue


data = [];

% starting_lumas = [50 100 50 500 5 80 50];

starting_lumas = [10 20 10 50 5 10 10];

for i=1:7

    EXIT_SIGNAL = 0;
    surrLumaJump = 0;
    unmatchs = 0;
    cont_matches = 0;
    cont_unmatches = 0;
    stimuli_counter = 1;
    prev_surrLumaInt = -1;
%     surrLumaInt = starting_lumas(i);


    pause_time = 10; % seconds
    start_time = GetSecs+1;
        
    adptSurrLuma = 0;
    st_luma = starting_lumas(i);
    step_size = double(st_luma/pause_time);

    while (GetSecs-start_time) < pause_time

        surrColor=i;
        if surrColor == 1 
            surrLuma = [adptSurrLuma adptSurrLuma adptSurrLuma];
        elseif surrColor == 2 
            surrLuma = [adptSurrLuma 0 0];
        elseif surrColor == 3 
            surrLuma = [0 adptSurrLuma 0];
        elseif surrColor == 4 
            surrLuma = [0 0 adptSurrLuma];
        elseif surrColor == 5 
            surrLuma = [adptSurrLuma adptSurrLuma 0]; %yellow
        elseif surrColor == 6 
            surrLuma = [adptSurrLuma 0 adptSurrLuma]; % magenta
        elseif surrColor == 7 
            surrLuma = [ 0 adptSurrLuma adptSurrLuma]; %cyan
        end



        x_c=0;y_c=0;
        [y,x]=ndgrid(-bg_r:bg_r,-bg_r:bg_r);
        
        background_c = (x-x_c).^2+(y-y_c).^2 >= (bg_r-10)^2;
        
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
        
    
    %     background = medfilt2(background, [5, 5]); % try smooth here
    
        background = imgaussfilt(background, 2); % try smooth here
    
        curr_sec = GetSecs+1;
        
        while(curr_sec-GetSecs)>0

    
            Screen('FillRect', win, surrLuma);
            texid = Screen('MakeTexture', win, background);
            Screen('DrawTexture', win, texid);
    
            Screen('Flip', win);
        end

        adptSurrLuma = adptSurrLuma + step_size;



    end
    Screen('Close');


    surrLumaInt = starting_lumas(i);
    while ~EXIT_SIGNAL

        prev_surrLumaInt = surrLumaInt;


        surrColor = i; 
        if surrColor == 1 || surrColor == 2
            surrLuma = [surrLumaInt surrLumaInt surrLumaInt];
        elseif surrColor == 3 || surrColor == 4
            surrLuma = [surrLumaInt 0 0];
        elseif surrColor == 5 || surrColor == 6
            surrLuma = [0 surrLumaInt 0];
        elseif surrColor == 7 || surrColor == 8
            surrLuma = [0 0 surrLumaInt];
        elseif surrColor == 9 || surrColor == 10
            surrLuma = [surrLumaInt surrLumaInt 0]; %yellow
        elseif surrColor == 11 || surrColor == 12
            surrLuma = [surrLumaInt 0 surrLumaInt]; % magenta
        elseif surrColor == 13 || surrColor == 14
            surrLuma = [ 0 surrLumaInt surrLumaInt]; %cyan
        end


        tic;
    
        
        x_c=0;y_c=0;
        [y,x]=ndgrid(-bg_r:bg_r,-bg_r:bg_r);
        
        background_c = (x-x_c).^2+(y-y_c).^2 >= (bg_r-10)^2;
        
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
        
        no_of_gaps = randi([2,11],1,1);
%         disp(no_of_gaps);
        gaps_real = [];

        if no_of_gaps>1
            rand_no = randi([1,4],1,1);
    
            if rand_no==1  %%  right
                rect = double(ones(c_height, st_r)) * backLuma;
                background(bg_r-c_height/2:bg_r+c_height/2-1, bg_r:bg_r+st_r-1,:) = cat(3, rect, rect,rect);
                gaps_real = [gaps_real, 6];
            elseif rand_no==2 %% left
                rect = double(ones(c_height, st_r)) * backLuma;
                background(bg_r-c_height/2:bg_r+c_height/2-1, bg_r-st_r+1:bg_r,:) = cat(3, rect, rect,rect);
                gaps_real = [gaps_real, 4];
            elseif rand_no==3 %% up
                rect = double(ones(st_r, c_height)) * backLuma;
                background(bg_r-st_r+1:bg_r, bg_r-c_height/2:bg_r+c_height/2-1,:) = cat(3, rect, rect,rect);
                gaps_real = [gaps_real, 8];
            elseif rand_no==4 %% down
                rect = double(ones(st_r, c_height)) * backLuma;
                background(bg_r:bg_r+st_r-1, bg_r-c_height/2:bg_r+c_height/2-1,:) = cat(3, rect, rect,rect); 
                gaps_real = [gaps_real, 2];
            end
%         else
%                 gaps_real = [gaps_real, 5];
        end
    
        if no_of_gaps>5

            rand_no2 = randi([1,4],1,1);
            
            diff = rand_no2~=rand_no;
            while ~diff
                rand_no2 = randi([1,4],1,1);
                if rand_no2 ~= rand_no
                    diff=1;
                end
            end
    
            if rand_no2==1
                rect = double(ones(c_height, st_r)) * backLuma;
                background(bg_r-c_height/2:bg_r+c_height/2-1, bg_r:bg_r+st_r-1,:) = cat(3, rect, rect,rect);
                gaps_real = [gaps_real, 6];
            elseif rand_no2==2
                rect = double(ones(c_height, st_r)) * backLuma;
                background(bg_r-c_height/2:bg_r+c_height/2-1, bg_r-st_r+1:bg_r,:) = cat(3, rect, rect,rect);
                gaps_real = [gaps_real, 4];
            elseif rand_no2==3
                rect = double(ones(st_r, c_height)) * backLuma;
                background(bg_r-st_r+1:bg_r, bg_r-c_height/2:bg_r+c_height/2-1,:) = cat(3, rect, rect,rect);
                gaps_real = [gaps_real, 8];
            elseif rand_no2==4
                rect = double(ones(st_r, c_height)) * backLuma;
                background(bg_r:bg_r+st_r-1, bg_r-c_height/2:bg_r+c_height/2-1,:) = cat(3, rect, rect,rect);         
                gaps_real = [gaps_real, 2];
            end
        end
    
    
        background_c2 = background_c;
        background_c2(bg_r-st_r:bg_r+st_r, bg_r-st_r:bg_r+st_r) = (~background_c2(bg_r-st_r:bg_r+st_r, bg_r-st_r:bg_r+st_r)) .* circle_1_c;
    
        background(background_c2) = backLuma;
        temp_1 = background(:,:,1);
        temp_2 = background(:,:,2);
        temp_3 = background(:,:,3);
        temp_1(background_c==1) = surrLuma(1);
        temp_2(background_c==1) = surrLuma(2);
        temp_3(background_c==1) = surrLuma(3);
        background = cat(3, temp_1, temp_2, temp_3);
    
    
        Screen('FillRect', win, surrLuma);
        texid = Screen('MakeTexture', win, background);
        Screen('DrawTexture', win, texid);
        Screen('Flip', win);
    
    
        stimuli_exit = 0;
        pressed_keys = [];
        while ~stimuli_exit
    
            KbQueueStart;        
    
            KbWait([],2); % press any key to start the movement
        
            KbQueueStop;
            [pressed, firstPress, firstRelease, lastPress, lastRelease]=KbQueueCheck;% check if space was pressed
            if pressed
                keyName = KbName(find(firstPress));
            
%                 if strcmp(keyName, '5')
%                     pressed_keys = [pressed_keys, 5];
                if strcmp(keyName, '2')
                    pressed_keys = [pressed_keys, 2];
                elseif strcmp(keyName, '4')
                    pressed_keys = [pressed_keys, 4];
                elseif strcmp(keyName, '8')
                    pressed_keys = [pressed_keys, 8];
                elseif strcmp(keyName, '6')
                    pressed_keys = [pressed_keys, 6];
                elseif strcmp(keyName, 'space')
                    if length(pressed_keys)>= 1
                        stimuli_exit = 1;
                    end
                elseif strcmp(keyName, '-')
                    pressed_keys = -1;
                elseif strcmp(keyName, '0')
                    pressed_keys = [];
                elseif strcmp(keyName, 'ESCAPE')
                    EXIT_SIGNAL = 1;
                    stimuli_exit = 1;
                end    
            end
        end


    

        is_match = 0;
        if sum(unique(gaps_real))==sum(unique(pressed_keys))
            is_match = 1;
            cont_matches = cont_matches + 1;
            cont_unmatches = 0;
    
            if surrLumaJump < 50
                surrLumaJump = (cont_matches*cont_matches)+1;
            end
%             if unmatchs >= 1 && unmatchs <= 3 && cont_matches >=2 && cont_matches < 5
%                 surrLumaJump = 10*(cont_matches+1);    
%            end
            % match
        else
            unmatchs = unmatchs + 1;
            cont_unmatches = cont_matches + 1;
            cont_matches = 0;

            if surrLumaJump < 0 || surrLumaJump == 1
                surrLumaJump = 1;
            else
                surrLumaJump = -surrLumaJump;
            end
%             if unmatchs==1 && stimuli_counter>1
%                 surrLumaInt = surrLumaInt - surrLumaJump;
%             end
%     
%             if surrLumaJump > 10 && surrLumaJump <= 50
%                 surrLumaJump = 10;
%             elseif surrLumaJump == 10 
%                 surrLumaJump = 5;
%             elseif surrLumaJump == 5
%                 surrLumaJump = 1;
%             end
            % unmatch
        end
    
        if unmatchs > 4  %surrLumaJump==1 && 
            EXIT_SIGNAL = 1;
        elseif surrLumaInt > 1023
            EXIT_SIGNAL = 1;
        end

        if cont_matches==5 && unmatchs > 0
            unmatchs = 0;
%             unmatchs = unmatchs - 1;
        end 

        timeTaken = toc;
    
        data = [data; [stimuli_counter, stimulusLuma, backLuma, prev_surrLumaInt, surrLumaJump, surrColor, {gaps_real}, {pressed_keys}, timeTaken, is_match]];
        stimuli_counter = stimuli_counter + 1;


        surrLumaInt = surrLumaInt + surrLumaJump;

        Screen('Close');

    end



end

KbQueueRelease;

t = cell2table(data,'VariableNames',{'Index' 'Stimulus' 'Background' 'Surrounding', 'Jump', 'Color', 'GapsR', 'GapsP', 'Time', 'Match'});
writetable(t,'test.csv');



Screen('CloseAll');
sca;

%% Time Calculation

% clc;
% 
% tic;
% disp(1);
% timeElapsed = toc;
% 
% disp(timeElapsed)


%% Write in a file
% tic;
% 
% timeElapsed = toc;
% 
% vals = [1, 0.5, 0, 1023.0, [5 10], [5 10], timeElapsed, 0 ];
% % vals = [1, 0.5, 0, 1023.0, 5, [5,10], , 0 ]
% 
% file_id=fopen('akash.csv','w');
% fprintf(file_id,'%.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f\n', vals);
% fclose(file_id);
% 


