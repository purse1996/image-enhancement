function img_new = My_CACHE(img)
[m ,n, c] = size(img);
if c==3
    img = rgb2gray(img);
else
    img = img;
end

img_new = zeros(m, n);
%获取不同分辨率图片构成金字塔

%cmpute_com计算dark-pass filter gradient
com1 = compute_com(img);
figure
 imshow(uint8(com1*255));        
 update1 = max(com1, 0.001);
 img2 = imresize(img, 1/2, 'bicubic');
 com2 = compute_com(img2);
 figure
 imshow(uint8(com2*255));      
 
 com2 = imresize(com2, [m, n], 'bicubic');
 update2 = max(com2, 0.001);
       
img3 = imresize(img, 1/4, 'bicubic');
com3 = compute_com(img3);
figure
imshow(uint8(com3*255));         
       
% com3 = imresize(com3,4 , 'bicubic');      
%直接bicubic无法回到原来大小
com3 = imresize(com3, [m, n], 'bicubic');      
update3 = max(com3, 0.001);


img4 = imresize(img, 1/(2*4), 'bicubic');       
com4 = compute_com(img4);
figure
imshow(uint8(com4*255));        
%  com4 = imresize(com4, 8, 'bicubic');
com4 = imresize(com4, [m, n], 'bicubic');
update4 = max(com4, 0.001);

%不同分辨率dark-pass filter的几何平均
update = (update1.*update2.*update3.*update4).^(1/4);
update_sum = sum(sum(update));

%重新定义的灰度概率
p_old = zeros(256, 1);
p_new = zeros(256,1);
for i=1:256
    for j=1:m
        for k=1:n
            p_old(i) = p_old(i) + update(j, k)*kroneckerDelta(double(img(j,k)), double(i-1))/update_sum;
        end
    end
end

%累积概率
for i=1:256
    if(i==1)
        p_new(i) = p_old(i);
    else
        p_new(i) = p_old(i) + p_new(i-1);
    end
end



% 灰度值的重新定义
for i=1:m
    for j=1:n
        img_new(i,j) = round(255*p_new(img(i,j)+1));
    end
end

img_new = uint8(img_new);
% subplot(1,2,1)
% imshow(img_origin);
% subplot(1,2,2)
% imshow(uint8(img_new));
end

%在调用matlab该函数出现了问题，故自己写了一个
function b = kroneckerDelta(c, d)
if c==d
    b =1;
else 
    b = 0;
end
end

function  com = compute_com(img)
    [m ,n] = size(img);
    com = zeros(m,n);
    img1 = [zeros(1,n); img];
    img2 = [img1; zeros(1,n)];
    img3 = [zeros(m+2,1), img2];
    img_padding = double([img3, zeros(m+2,1)]);
    %为了简化计算，故邻域只取了4个点
    for i=1:m
        for j=1:n
            NE1 = min((img_padding(i+1,j+1)-img_padding(i,j+1))/255, 0);
            NE2 = min((img_padding(i+1,j+1)-img_padding(i+1,j))/255, 0);
            NE3 = min((img_padding(i+1,j+1)-img_padding(i+2,j+1))/255, 0);
            NE4 = min((img_padding(i+1,j+1)-img_padding(i+1,j+2))/255, 0);
            com(i, j) = -(NE1 + NE2 + NE3 + NE4);
        end
    end    
end
