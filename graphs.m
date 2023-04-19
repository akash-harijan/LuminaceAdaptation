clc;
clear all;

% data = readtable('Results/Giorgio/1,test.csv');
data = readtable('test.csv');


colors = unique(data.Color);
color_names = ["White", "Red", "Green", "Blue", "Yellow", "Magenta", "Cyan"];

% color_names	= ["Blue", "Yellow"];
% test = [4 5];

for i=1:length(colors)
    disp(colors(i));
    graph_data = data.Surrounding(data.Color==colors(i));

    
    figure()
    plot(graph_data, '-o')
    title('Circles and Lines')
    title(color_names(i))

end
