
clear all;
clc;

% data = readtable('test.csv');
% data =  readtable('Testing\Akash-7C-4S-test.csv');
% data =  readtable('Testing\Ehsan-7C-4S-test.csv');
data =  readtable('Testing\Ivar-7C-4S-test.csv');

key1_wrong = data.GapsR_1(data.Match==0);
key1_correct = data.GapsR_1(data.Match==1);


key2_wrong = rmmissing(data.GapsR_2(data.Match==0));
key2_correct = rmmissing(data.GapsR_2(data.Match==1));

key2_wc = histcounts(key2_wrong,4);
key2_cc = histcounts(key2_correct, 4);


[n1, x1] = hist(key1_wrong, 4, [2, 4, 6, 8]);
[n2, x2] = hist(key1_correct, 4, [2, 4, 6, 8]);

n1 = n1 + key2_wc;
n2 = n2 + key2_cc;

n = n1 + n2;


total = [n(1)+n(4) n(2)+n(3)];
wrong = [n1(1)+n1(4) n1(2)+n1(3)];
correct = [n2(1)+n2(4) n2(2)+n2(3)];


x = [1 2];
y = total;

figure

h = bar([1 2], [total;wrong;correct]);
xticklabels({'Vertical','Horizontal'});
% h = bar([2, 4, 6, 8],[n1;n2]);
set(h(1), 'FaceColor', 'Blue');
set(h(2), 'FaceColor', 'red');
set(h(3), 'FaceColor', 'green');

v_wrong_perc = (wrong(1)/total(1))*100 ;
v_correct_perc = (correct(1)/total(1))*100;

h_wrong_perc = (wrong(2)/total(2))*100;
h_correct_perc = (correct(2)/total(2))*100;

wrong_perc = [v_wrong_perc h_wrong_perc];
correct_perc = [v_correct_perc, h_correct_perc];

for i=1:length(x)
    text(x(i)-0.2,total(i),num2str(100),'HorizontalAlignment','center','VerticalAlignment','bottom')
    text(x(i),wrong(i),num2str(wrong_perc(i)),'HorizontalAlignment','center','VerticalAlignment','bottom')
    text(x(i)+0.2,correct(i),num2str(correct_perc(i)),'HorizontalAlignment','center','VerticalAlignment','bottom')
end



disp(v_wrong_perc)
disp(v_correct_perc);
disp(h_wrong_perc)
disp(h_correct_perc);



%%

clc;
clear all;

data =  readtable('Testing\Akash-7C-4S-test.csv');
% data =  readtable('Testing\Ehsan-7C-4S-test.csv');
% data =  readtable('Testing\Ivar-7C-4S-test.csv');

% data = data(data.Color==1,:); % sanity test


% get real both gaps showed
key1_wrong_R = data.GapsR_1(data.Match==0);
key2_wrong_R = data.GapsR_2(data.Match==0);

non_nan_indices_R = find(~isnan(key2_wrong_R));

gap_1_R = key1_wrong_R(non_nan_indices_R);
gap_2_R = key2_wrong_R(non_nan_indices_R);


% get pressed both gaps 
key1_wrong_P = data.GapsP_1(data.Match==0);
key2_wrong_P = data.GapsP_2(data.Match==0);

% non_nan_indices_P = find(~isnan(key2_wrong_P));

gap_1_P = key1_wrong_P(non_nan_indices_R);
gap_2_P = key2_wrong_P(non_nan_indices_R);

gaps_R = cat(2, gap_1_R, gap_2_R);
gaps_P = cat(2, gap_1_P, gap_2_P);

missed_gaps = [];
for i=1:length(gaps_R)
    for j=1:2
        key = gaps_R(i, j);
        if ~ismember(key, gaps_P(i,:))
            missed_gaps  = [missed_gaps, key];
        end

    end
end


all_gaps = gaps_R(:);

all_gaps_count = [sum(all_gaps==2) sum(all_gaps==4) sum(all_gaps==6) sum(all_gaps==8)];
missed_gaps_count = [sum(missed_gaps==2) sum(missed_gaps==4) sum(missed_gaps==6) sum(missed_gaps==8)];

% in case we all have 4 values in our array otherwise it wont work.
% all_gaps_count = histcounts(all_gaps, 4);
% missed_gaps_count = histcounts(missed_gaps, 4);


all_gaps_vh = [all_gaps_count(1)+all_gaps_count(4) all_gaps_count(2)+all_gaps_count(3)];
missed_gaps_vh = [missed_gaps_count(1)+missed_gaps_count(4) missed_gaps_count(2)+missed_gaps_count(3)];
correct_gaps_vh = all_gaps_vh-missed_gaps_vh;


figure

h = bar([1 2], [all_gaps_vh;missed_gaps_vh;correct_gaps_vh]);
xticklabels({'Vertical','Horizontal'});
set(h(1), 'FaceColor', 'Blue');
set(h(2), 'FaceColor', 'red');
set(h(3), 'FaceColor', 'green');


v_wrong_perc = (missed_gaps_vh(1)/all_gaps_vh(1))*100 ;
v_correct_perc = (correct_gaps_vh(1)/all_gaps_vh(1))*100;

h_wrong_perc = (missed_gaps_vh(2)/all_gaps_vh(2))*100;
h_correct_perc = (correct_gaps_vh(2)/all_gaps_vh(2))*100;

wrong_perc = [v_wrong_perc h_wrong_perc];
correct_perc = [v_correct_perc, h_correct_perc];

x = [1 2];
for i=1:length(x)
    text(x(i)-0.2,all_gaps_vh(i),sprintf('%.2f',100)+"%",'HorizontalAlignment','center','VerticalAlignment','bottom')
    text(x(i),missed_gaps_vh(i),sprintf('%.2f',wrong_perc(i))+"%",'HorizontalAlignment','center','VerticalAlignment','bottom')
    text(x(i)+0.2,correct_gaps_vh(i),sprintf('%.2f',correct_perc(i))+"%",'HorizontalAlignment','center','VerticalAlignment','bottom')
end




%%

% % Sample data
% x = [1 2 3 4 5];
% y = [3 5 2 7 4];
% 
% % Create figure and plot bar chart
% figure;
% bar(x,y);
% 
% % Set x-axis tick labels
% xticklabels({'Category 1', 'Category 2', 'Category 3', 'Category 4', 'Category 5'});
% 
% % Set x-axis label
% xlabel('Categories');
% 
% % Set y-axis label
% ylabel('Values');
% 
% % Add text labels to bars
% for i=1:length(x)
%     text(x(i),y(i),num2str(y(i)),'HorizontalAlignment','center','VerticalAlignment','bottom')
% end

%%

% % Sample data
% x = [1 2 3 4 5];
% y1 = [3 5 2 7 4];
% y2 = [2 4 6 1 5];
% 
% % Create figure and plot side-by-side bar chart
% figure;
% bar([y1' y2']);
% 
% % Set x-axis tick labels
% xticklabels({'Category 1', 'Category 2', 'Category 3', 'Category 4', 'Category 5'});
% 
% % Set x-axis label
% xlabel('Categories');
% 
% % Set y-axis label
% ylabel('Values');
% 
% % Add legend
% legend({'Group 1', 'Group 2'});
% 
% % Add labels to each bar
% text(1:size([y1' y2']), [y1' y2'], num2str([y1' y2']), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Position', [0, 0.1, 0]);
