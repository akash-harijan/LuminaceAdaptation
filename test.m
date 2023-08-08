
%%

clear all;
clc;

x = 0.3127;
y = 0.3290;
z = 1-(x+y);

R = [0.6864 0.3110];
G = [0.2169 0.7235];
B = [0.1498 0.0546];

X= x/y;
Y= y/y;
Z = z/y;

rgbs1 = [0 0 0; 32 0 0; 64 0 0; 128 0 0; 255 0 0 ;1023 0 0 ];
rgbs2 = [0 0 0; 0 32 0; 0 64 0; 0 128 0; 0 255 0 ;0 1023 0 ];
rgbs3 = [0 0 0; 0 0 32; 0 0 64; 0 0 128; 0 0 255 ;0 0 1023 ];
rgbs4 = [0 0 0; 32 32 32; 64 32 32; 128 128 128; 255 255 255 ;1023 1023 1023 ];

catrgb = cat(1, rgbs1, rgbs2, rgbs3, rgbs4);


labs = rgb2lab(catrgb, WhitePoint=[X Y Z]);

catall = cat(2, catrgb, labs);

writematrix(catall,'test.xlsx');





%% RGB2Lab with Ali
% reference: High Dyanmic range imaging by eric reinhard page no 35 color
% spaces to see the formual of matrix.

clear all;
clc;

addpath('D:\Softwares\ColourEngineeringToolbox\colour');

x = 0.3127;
y = 0.3290;
z = 1-(x+y);

R = [0.6864 0.3110];
G = [0.2169 0.7235];
B = [0.1498 0.0546];

X= x/y;
Y= y/y;
Z = z/y;

% 
% XYZ = [R(1)/R(2) R(2)/R(2) (1-sum(R))/R(2)
% G(1)/G(2) G(2)/G(2) (1-sum(G))/G(2);
% B(1)/R(2) B(2)/B(2) (1-sum(B))/B(2);
% ];



xyz = [R(1) R(2) (1-sum(R));
G(1) G(2) (1-sum(G));
B(1) B(2) (1-sum(B));
];


wp = [X Y Z];

xyz = xyz';

s = xyz\wp';

newXYZ = zeros(3,3);

newXYZ(:, 1) = xyz(:,1)*s(1);
newXYZ(:, 2) = xyz(:,2)*s(2);
newXYZ(:, 3) = xyz(:,3)*s(3);

rgbs1 = [0 0 0; 32 0 0; 64 0 0; 128 0 0; 255 0 0 ;1023 0 0 ];
rgbs2 = [ 0 32 0; 0 64 0; 0 128 0; 0 255 0 ;0 1023 0 ];
rgbs3 = [0 0 32; 0 0 64; 0 0 128; 0 0 255 ;0 0 1023 ];
rgbs4 = [32 32 32; 64 64 64; 128 128 128; 255 255 255 ;1023 1023 1023 ];

catrgb = cat(1, rgbs1, rgbs2, rgbs3, rgbs4)/1023;

% 
convXYZ = newXYZ*catrgb';
convXYZ = convXYZ';

lab = xyz2lab(convXYZ, wp);

catall = cat(2, catrgb*1023, convXYZ);
catall = cat(2, catall, lab);

% 
% writematrix(catall,'test2.xlsx');


%% 

scatter3(lab(:,2), lab(:,3), lab(:,1))
hold on
scatter3(lab(1:6,2), lab(1:6,3), lab(1:6,1), 'r')
scatter3(lab(7:11,2), lab(7:11,3), lab(7:11,1), 'g')
scatter3(lab(12:16,2), lab(12:16,3), lab(12:16,1), 'b')
scatter3(64.31283869, 51.01090523, 80, 'm')
hold off

		


%%
% lab = [90	102.1902583/2	95.49258781/2 ];


lab = [80	64.31283869	51.01090523];
xyz = lab2xyz(lab, wp);

rgb = newXYZ\xyz';
disp(rgb);


patch = ones(256,256,3);
patch(:,:,1) = rgb(1);
patch(:,:,2) = rgb(2);
patch(:,:,3) = rgb(3);

imshow(patch);



%% testing the QUEST

clc;
clear all;


% Define stimulus and experimental parameters
surrRange = logspace(log10(0.01),log10(1),100); % range of stimulus levels
nTrials = 49; % number of trials
threshold = 0.5; % desired threshold level


% Initialize QUEST object
tGuess=0;tGuessSd=50;pThreshold=0.5;beta=3.5;delta=0.01;gamma=0.5;grain=0.01;range=1000;

q = QuestCreate(tGuess, tGuessSd, pThreshold,beta, delta, gamma,grain, range);

% Loop through trials
rps = [1	1	1	1	1	1	1	0	1	1	1	1	1	1	1	0	1	0	1	0	1	1	1	1	0	1	1	1	1	1	0	0	1	1	1	0	0	1	1	1	1	1	1	1	0	0	0	0	0];
rps = ~rps;
stimlevels = [];
for iTrial = 1:nTrials
    % Get recommended stimulus level from QUEST
    stimLevel = QuestQuantile(q);
%     stimLevel = QuestMean(q);

    if stimLevel <0
        stimLevel = -1*stimLevel;
    end

    %   tTest=QuestQuantile(q);	% Recommended by Pelli (1987), and still our favorite.
	% 	tTest=QuestMean(q);		% Recommended by King-Smith et al. (1994)
	% 	tTest=QuestMode(q);	
    stimlevels = [stimlevels, stimLevel];

    disp(stimLevel);
    % Present stimulus and record response (1 = seen, 0 = not seen)
    response = rps(iTrial); %presentStimulusAndGetResponse(stimLevel);
    
    % Update QUEST with response
    q = QuestUpdate(q,stimLevel,response);
end

% Get estimated threshold level
thresholdEst = QuestMean(q);
disp('Est : ')
disp(thresholdEst);

figure()
plot(stimlevels);




%%



%  DIM P(80),Q(40),QO(40),S(l,80) \ N=20 \ N2=2*N \ S=12 \ D=.Ol \ G=.5 \ B=3.5/20 \ E=1.5 \ M:32
%  FOR X=-N2 TO N2 \ P(N2+X)=1-(1-G)*EXP(-10 A(B*(X+E») \ IF P(N2+X»1-D THEN P(N2+X)=1-D
%  S(O,N2-X)=LOG(1-P(N2+X» \ S(l,N2-X)=LOG(P(N2+X» \ NEXT X
%  FOR T=-N TO N \ QO(N+T)=-(T/S)A2 \ Q(N+T)=QO(N+T) \ NEXT T
% PRINT "Prior estimate (+I-";S;"dB)"; \ INPUT TO \ PRINT "Actual threshold"; \ INPUT Tl
% 150 FOR K=l TO M
% 160 GOSUB 220 \ R=INT(P(N2+X+TO-Tl)+RND(O» \ PRINT "Tdal";K;"at ";X+TO;"dB has response";R
% 110 FOR T=-N TO N \ Q(N+T)=Q(N+T)+S(R,N2+T-X) \ NEXT T
% 180 NEXT K
% 190 FOR T=-N TO N \ Q(N+T)=Q(N+T)-QO(N+T) \ NEXT T
% 200 GOSUB 220 \ PRINT "Maximum likelihood estimate is ";X+TO;"dB"
% 210 STOP
% 220 X=-N \ FOR T=-N TO N \ IF Q(N+T»Q(N+X) THEN X=T
% 230 NEXT T \ RETURN


%%


% luma = 100;
% while true
%     
%     disp(luma);
%     luma = luma + 100;
% 
%     pause
%         
% end


% rgb = [1023 0 0];
% ycbcr = rgb2ycbcr(rgb);
% % disp(ycbcr(1))
% 
% min = 16/255;
% max = 235/255;
% 
% disp(ycbcr(1));
% Y = (ycbcr(1))/255;
% disp(Y);

% set(win, 'WindowKeyPressFcn', @keyPressCallback);
% 
% function keyPressCallback(~, eventdata)
% 
%     keyPressed = eventdata.Key;
%     if strcmpi(keyPressed, 'rightarrow')
%         luma = luma + 100;
%     elseif strcmpi(keyPressed, 'leftarrow')
%         luma = luma - 100;
% 
%     elseif strcmpi(keyPressed, 'escape')
%         break
%     end
% 
% end

%%



rgb = [1 1 1];
lab_w = rgb2lab(rgb);
lch_w = lab2lch(lab_w)/100.0;

rgb = [1 0 0];
lab_r = rgb2lab(rgb);
lch_r = lab2lch(lab_r)/100.0;


rgb = [0 0 1];
lab_b = rgb2lab(rgb);
lch_b = lab2lch(lab_b)/100.0;

rgb = [0 1 0];
lab_g = rgb2lab(rgb);
lch_g = lab2lch(lab_g)/100.0;


rgb = [1 1 0];
lab_y = rgb2lab(rgb);
lch_y = lab2lch(lab_y)/100.0;
