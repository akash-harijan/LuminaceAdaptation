clc;
clear all;

% data = readtable('Results\Ahsan\test.csv');
% data = readtable('Results\Steven\4-20-23-test.csv');
% data = readtable('test.csv');
data = readtable('Testing\Ehsan-7C-4S-test.csv');
% data = readtable('Results\Giorgio\3-6-4-23-test.csv');
% data = readtable('Results\Greg\test.csv');


colors = unique(data.Color);


% color_names	= ["Blue", "Yellow"];
% test = [4 5];

% figure()
% t = tiledlayout(4,4);
% color_names = ["White","White", "Red", "Red", "Green","Green", "Blue", "Blue","Yellow","Yellow", "Magenta", "Magenta", "Cyan", "Cyan"];


figure()
t = tiledlayout(3,3);
color_names = ["White", "Red", "Green", "Blue", "Yellow", "Magenta", "Cyan"];

for i=1:length(colors)
    disp(colors(i));
    graph_data = data.Surrounding(data.Color==colors(i));

    
%     figure()
    nexttile
    plot(graph_data, '-o')
    title('Circles and Lines')
    title(color_names(i))

end
