%Direct Calibration by Fitting of Cuboids to a Single Image Using Differential Evolution
%Luis Gerardo de la Fraga & Oliver Sch锟絫ze
%script of reconstruction a cuboid
%Primitives/Images/cuboid/cardboard_box/1790648.jpg

clear
%close all

im = imread('./data/box3.jpg');
x=[ ...
    257.2424  138.9868
    18.6689   40.1650
    243.6928  443.2831
    480.1527   82.6817
    39.8361  251.4808
    210.9583   19.6815
    436.2677  327.5866];

indexMapping=[2 3 6 1 7 4 5];

% im = imread('2112.jpg');
% x=[ ...
%     246.2  182
%     152   156.9
%     258.2  334
%     384.8  108.8
%     170.8 303
%     297.5 90.5
%     386.2 244.8];
% 
% indexMapping=[2 3 6 1 7 4 5];


% im = imread('box1.png');
% x=[ ...
%     283 287 
%     281 362 
%     474 346 
%     463 430 
%     527 339 
%     537 271 
%     377 233 ];
% 
% indexMapping=[3, 7, 2, 6, 5, 1, 4];


x(indexMapping,:) = x   

%x(:,2) = -x(:,2);

imshow(im);
hold on;
for i=1:7
    plot(x(i,1),x(i,2),'bo');
%     plot(x(i,1),x(i,2),'g+');
    pause;
end

% 图像坐标系放置在图像中间，并用图像面积对像素坐标进行归一化
width = size(im,2);
height = size(im,1);
scale = sqrt(width * height)/2;

x(:,1) = (x(:,1)-width/2)/scale;
x(:,2) = (x(:,2)-height/2)/scale;

idx = true(1,7);

X = reconstructCuboid(x,idx);

[w3,l,M] = intrinsicCuboid(X);

%    M is decomposed into the form M = K*[R -R*C]
[K, R, C, pp, pv] = decomposecamera(M)
K  = K/K(3,3);


figure(1)
clf
imshow(im);
hold on
plot(x(:,1)*scale+width/2,x(:,2)*scale+height/2,'g+');
Cidx = [ ...
+1 +1 +1 1; ...
+1 -1 +1 1; ...
-1 -1 +1 1; ...
-1 +1 +1 1; ...
+1 +1 -1 1; ...
+1 -1 -1 1; ...
-1 -1 -1 1; ...
-1 +1 -1 1]';



x_repro = X * Cidx;
x_repro = x_repro ./ repmat(x_repro(3,:),3,1);
x_repro = x_repro';
x_repro(:,1)=x_repro(:,1)*scale+width/2;
x_repro(:,2)=x_repro(:,2)*scale+height/2;


x_3D = diag(l) * Cidx;
x_3D = x_3D ./ repmat(x_3D(4,:),4,1);
x_3D = x_3D';

index4draw = [1 2 1; 2 3 1; 3 4 1; 4 1 1; 1 5 1; 5 6 1; 6 7 1; 2 6 1; 3 7 1; 7 8 0; 5 8 0; 4 8 0];

for i=1:size(index4draw)
    edgex  = [x_repro(index4draw(i,1),1) x_repro(index4draw(i,2),1)];
    edgey = [x_repro(index4draw(i,1),2) x_repro(index4draw(i,2),2)];
    if index4draw(i,3)
        plot(edgex, edgey, '-r');
    else
        plot(edgex, edgey, '-.r');
    end
end

plot(x_repro(:,1),x_repro(:,2),'bo');
axis tight

figure(2)
clf
plot3(x_3D(:,1),x_3D(:,2),x_3D(:,3),'b+');
hold on
for i=1:size(index4draw)
    edgeX = [x_3D(index4draw(i,1),1) x_3D(index4draw(i,2),1)];
    edgeY = [x_3D(index4draw(i,1),2) x_3D(index4draw(i,2),2)];
    edgeZ = [x_3D(index4draw(i,1),3) x_3D(index4draw(i,2),3)];
    if index4draw(i,3)
        plot3(edgeX, edgeY, edgeZ, '-r');
    else
        plot3(edgeX, edgeY, edgeZ, '-.r');
    end
end
axis equal

plot3(C(1),C(2),C(3),'*r');
l4vis = norm(C);
plot3([C(1) C(1)*0.8],[C(2) C(2)*0.8],[C(3) C(3)*0.8],'-k');


l4vis = 0.025*l4vis;

Corner = [0 0 K(1,1)*l4vis*2 1]';
T(1:3,:)=[R -R*C];
T(4,:) = [0 0 0 1];
Corner = inv(T)*Corner;
plot3([C(1) Corner(1)],[C(2) Corner(2)],[C(3) Corner(3)],'-k');

Corner = [width/scale*l4vis height/scale*l4vis K(1,1)*l4vis 1]';
T(1:3,:)=[R -R*C];
T(4,:) = [0 0 0 1];
Corner = inv(T)*Corner;
plot3([C(1) Corner(1)],[C(2) Corner(2)],[C(3) Corner(3)],'-b');
Corners(1,:)=Corner;

Corner = [-width/scale*l4vis height/scale*l4vis K(1,1)*l4vis 1]';
T(1:3,:)=[R -R*C];
T(4,:) = [0 0 0 1];
Corner = inv(T)*Corner;
plot3([C(1) Corner(1)],[C(2) Corner(2)],[C(3) Corner(3)],'-b');
Corners(2,:)=Corner;

Corner = [-width/scale*l4vis -height/scale*l4vis K(1,1)*l4vis 1]';
T(1:3,:)=[R -R*C];
T(4,:) = [0 0 0 1];
Corner = inv(T)*Corner;
plot3([C(1) Corner(1)],[C(2) Corner(2)],[C(3) Corner(3)],'-b');
Corners(3,:)=Corner;

Corner = [width/scale*l4vis -height/scale*l4vis K(1,1)*l4vis 1]';
T(1:3,:)=[R -R*C];
T(4,:) = [0 0 0 1];
Corner = inv(T)*Corner;
plot3([C(1) Corner(1)],[C(2) Corner(2)],[C(3) Corner(3)],'-b');
Corners(4,:)=Corner;


% plot3(Corners([1:4 1],1),[C(2) C(2)*0.8],[C(3) C(3)*0.8],'-b');
axis tight


