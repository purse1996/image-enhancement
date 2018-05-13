function img_new = histeq_new(img)
%在该代码中以灰度值范围为0-255为例

p_old = zeros(256,1);
p_new = zeros(256,1);
[m, n]  = size(img);
img_new = zeros(m,n);
pixels = m*n;

%求灰度值的概率密度
for i=1:256
    p_old(i) = sum(sum(img==i-1));
end
p_old = p_old/pixels;

%求概率密度的累积函数
for i=1:256
    if(i==1)
        p_new(i) = p_old(i);
    else
        p_new(i) = p_old(i) + p_new(i-1);
    end
end


%灰度值的重新分布
for i=1:m
    for j=1:n
        img_new(i,j) = round(255*p_new(img(i,j)+1));
    end
end

subplot(1,2,1);
imshow(img);
subplot(1,2,2);
imshow(uint8(img_new));

end 
