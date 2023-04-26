
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
