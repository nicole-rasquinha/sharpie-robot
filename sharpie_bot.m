filename = 'zebra.bmp';
ratio_pixels_to_dots = 8;

%%
bmp_file = imread(filename);
bmp_file = double(bmp_file)/255.0;
image_grayscale = bmp_file;
image_grayscale(:, :, 1) = 0.2989*bmp_file(:, :, 1) + 0.5780*bmp_file(:, :, 2) + 0.1140*bmp_file(:, :, 3);
image_grayscale(:, :, 2) = image_grayscale(:, :, 1);
image_grayscale(:, :, 3) = image_grayscale(:, :, 1);

% figure()
% imagesc(image_grayscale)
% title('Grayscale')

%%
gray_image = image_grayscale;
north = [0 -1 0
        0 1 0
        0 0 0];
east = [0 0 0
        0 1 -1
        0 0 0];
y_north = gray_image;
y_north(:, :, 1) = conv2(y_north(:, :, 1), north, 'same');
y_hn = abs(y_north);

y_east = gray_image;
y_east(:, :, 1) = conv2(y_east(:, :, 1), east, 'same');
y_he = abs(y_east);

threshold = 0.03;

z_hn = y_hn;
for k=1:size(y_hn, 1)
    for l=1:size(y_hn, 2)
        if y_hn(k, l, 1)>threshold
            z_hn(k, l, 1) = 1;
        else
            z_hn(k, l, 1) = 0;
        end
    end
end

z_he = y_he;
for k=1:size(y_he, 1)
    for l=1:size(y_he, 2)
        if y_he(k, l, 1)>threshold
            z_he(k, l, 1) = 1;
        else
            z_he(k, l, 1) = 0;
        end
    end
end

z = z_he;
for k=1:size(z_he, 1)
    for l=1:size(z_he, 2)
        if z_hn(k, l, 1)==1
            z(k, l, 1) = 1;
        end
    end
end

%getting rid of black edges from convolution
s = size(z);
z = z(1:s(1)-1, 2:s(2), :);

%switching the values of z for technicallity
z = 1 - z;
z = 255*z;

z(:, :, 2) = z(:, :, 1);
z(:, :, 3) = z(:, :, 1);

figure()
imagesc(z)
title('Edges in Image')
edgy = z;


%%
desired_image = edgy;
intensities = desired_image(:, :, 1);

rows = size(intensities, 1);
cols = size(intensities, 2);
compose_img = 255*ones(rows, cols, 3);

one_dim_intensities = 255 - reshape(intensities', 1, rows*cols);


for k=1:rows*cols/ratio_pixels_to_dots
    a = 1:size(one_dim_intensities, 2);             %# possible numbers
    w = one_dim_intensities;        %# corresponding weights
    N = 1;              %# how many numbers to generate

    elem = a( sum( bsxfun(@ge, rand(N,1), cumsum(w./sum(w))), 2) + 1 );

    row = floor((elem-1)/cols) + 1;
    col = mod(elem, cols);
    
    if col==0
        col = cols;
    end
    compose_img(row, col, :) = 0;
end

figure()
imagesc(compose_img)
title('Dots')
