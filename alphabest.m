
clear all;



% C = im2gray(imread('C-removebg-preview.png'));

% C = im2gray(imread('C.png'));
% C(C>128)=255;
% C(C<=128)=0;
% imwrite(C, 'C-.png');


C = im2gray(imread('C-.png'));

imshow(C);
unique(C)


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
