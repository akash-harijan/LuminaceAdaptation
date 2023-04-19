% Clear the workspace and the screen
sca;
close all;

% collecting observer ID:
IDc = inputdlg('Please enter your ID:','ID',1); ID = str2num(IDc{1,1});
if isnan(ID), errordlg('ID is not valid.','ERROR'); return; end
if (ID<1), errordlg('ID is not valid.','ERROR'); return; end

try

% initialization of Psych Toolbox (setting 10bit buffer, floating point precision for the texture, getting screen parameters, and loading identity LUT to the graphic card??)
AssertOpenGL;
Screen('Preference', 'SkipSyncTests', 0);
screenNumber = 0;
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
disableDithering = 1;
PsychImaging('AddTask', 'General', 'EnableNative10BitFramebuffer', disableDithering);
[mainwin, screenrect] = PsychImaging('OpenWindow', screenNumber, 0);
W = screenrect(3); H = screenrect(4); scenter = [W/2, H/2];
LoadIdentityClut(mainwin); % check this
Screen('TextSize', mainwin, 16);

% 10-bit test:
P = 512;im = [80:1/4:80+(P-1)/4];im = repmat(im,[P,1,3])/256;
tex = Screen('MakeTexture', mainwin, im, [], [], 1);
Screen('DrawTexture', mainwin, tex, [], [W/2-P/2,H/2-P/2,W/2-P/2+P-1,H/2-P/2+P-1], [], [], 1);
Screen('Flip', mainwin);
KbWait;WaitSecs(0.1);

N = 24; % number of different thresholds

% init QUEST params:
initSD = 1*ones(1,N); % initSD = [1,2,3,1...]
pTh = 0.75;   % probability of correct answer at threshold
beta = 3.5;   % steepness of Weibull function
delta = 0.01; % mistouch rate
gamma = 0.5; % probability of a random correct answer
tGuess = log10(2*ones(1,N));
for i = 1:N
    Q(i) = QuestCreate(tGuess(i), initSD(i), pTh, beta, delta, gamma);
end
TRIALSperTH = 20;
TOTALTRIALS = TRIALSperTH * N;

% your background
bckg1 = ones(H,W,3);
%testing:
bckgRGB = [0.5,0.5,0.5];
bckg1(:,:,1) = (double(bckgRGB(1)));
bckg1(:,:,2) = (double(bckgRGB(2)));
bckg1(:,:,3) = (double(bckgRGB(3)));

% stimuli:
stW = 1200; % stimuli width
stH = 1200; % stimuli height

stloc1 = [401,401+stW,401,401+stH]; % location1 (leftX, rightX, upY, downY)
stloc2 = [401+scenter(1),401+scenter(1)+stW,401,401+stH]; % location2

% RGB values (0-1) for the N references:
RefPatches = zeros(1,N,3);

% windows-thing:
Priority(MaxPriority(mainwin));

cnt = 0;

while (cnt < TOTALTRIALS),
    cnt = cnt + 1;
    
    % reseting mouse position:
    SetMouse(scenter(1),scenter(2));
    ShowCursor('Arrow');
    
    % randomizer for which of the N thresholds:
    chN = round(0.5 + rand*N); % equi-probable Ns
    
    % Get recommendation from QUEST for the stimuli value
    testingMagnitude = 10^QuestQuantile(Q(chN)); % this threshold will be tested
        
    % getting a random location for the reference:
    rndpos = 1 + round(rand); % either 1 or 2
    if (rndpos==1),  % the reference is displayed on the left
        st = bckg1;
        st(stloc1(3):stloc1(4),stloc1(1):stloc1(2),:) = ref(1,chN,:);
        st(stloc2(3):stloc2(4),stloc2(1):stloc2(2),:) = calcRGBValue;
    end
    if (rndpos==2),  % the reference is displayed on the right
        st = bckg1;
        st(stloc1(3):stloc1(4),stloc1(1):stloc1(2),:) = calcRGBValue;
        st(stloc2(3):stloc2(4),stloc2(1):stloc2(2),:) = ref(1,chN,:);
    end
   
    % setting the st screen-sized image as texture and displaying it 
    tex = Screen('MakeTexture', mainwin, st, [], [], 1);
    Screen('DrawTexture', mainwin, tex, [], [0,0,W,H], [], [], 1);
    %Screen('DrawText', mainwin, ['Remaining: ',num2str(TOTALTRIALS-cnt+1)], W/2-50, 40, [0,0,0]);
    Screen('Flip', mainwin); Screen('Close', tex);
    beep; 
    
    % waiting for mouse press:
    MousePress = 0;
    while (MousePress == 0),
        [click,x,y,buttons] = GetClicks(); 
        MousePress = any(buttons); %sets to 1 if a button was pressed and exits the while loop      
    end
    
    % checking for exit-condition (double-click in top-left)
    if ((x<10)&&(y<10) && ((buttons==3)||(buttons==2)) && (click == 2)), break; end  % an extra exit-condition: mouse click in the top-left corner
    
    % setting the screen with background color:
    tex = Screen('MakeTexture', mainwin, bckg1, [], [], 1);
    Screen('DrawTexture', mainwin, tex, [], [0,0,W,H], [], [], 1);
    Screen('Flip', mainwin); Screen('Close', tex);
    
    % checking for correct or false input from observer:
    correct = false;
    if (rndpos==1),
        if ( x < scenter(1)  ), correct = true; ccnt = ccnt + 1; end
    end
    if (rndpos==2),
        if ( x > scenter(1)  ), correct = true; ccnt = ccnt + 1; end
    end
    
    % updating the QUEST with observer's input:
    Q(chN) = QuestUpdate(Q(chN), log10(Mag(chN)), correct);
    
end

filename = ['rez_', num2str(ID), '_', datestr(now,'dd.mm.yyyy_HH.MM.SS'), '.mat'];
save(filename,'ID','Q');

sca;

catch
    sca;
end








