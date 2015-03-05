
%% Lab: Image Formation
% Authors:
% Sun Han (#3745)
% Renn Jervis (#3762)

%% Introduction
% In this lab we beigin processing a set of greyscale images to examine the
% properties of noise and begin to look at and manipulate plots of this
% noise.

%% A. Loading Images
% We begin by leading images from a specific directory and read them in
% matlab using the rawread command. We display one of the original images
% and then load the rest of the images into an array.

warning('off', 'images:initSize:adjustingMag');

cd /home/weinman/courses/CSC262/images/raw;

imgs = rawread('pic1.raw');

% A.2 One of the stock images
figure;

imshow (imgs);
title('original image');

% We want load several pictures in a similar manner and so loop through to
% load all raw image data

for  k=1:10
imgs(:,:,k) = rawread(['pic' num2str(k) '.raw']);
end;

%% B. Processing Images
% Then we must convert the images to doubles so we can do matrix
% arithmetic. We want the standard deviation for each pixel among the 10
% pictures so that we may analyze the noise. We first find image difference
% by subtracting the mean image from each original pixel. We square the
% result using .^ notation and find the varience by summing these values.
% From the variance we find the standard deviation by taking the square 
% root.

imgs = im2double(imgs);

imgMean = sum(imgs,3);

imgMean = imgMean/10;

imgDiff = bsxfun(@minus,imgMean, imgs);

imgDiffSqr = imgDiff.^2;

imgVar = sum(imgDiffSqr,3);

imgStdDev = imgVar.^(0.5);

%% C. Analyzing Noise

figure; % Open a new figure window to show standard dev image

imshow(imgStdDev,[]);
title('Adjusted Noise Image');
%% 
% C.2 The parts of the image with the most noise seemed to be two specific
% points of blank wall that appeared the most bright in the original
% images. The deviation image does not show the checkerboard pattern
% observed in the original images, but the areas of most noise have a more
% apparent pattern than the rest of the deivation image. Perhaps the
% brighter portions of the image produce most noise becase the 3 different
% types of photoreceptors do not necessarily read the same brightness value
% between pictures.

%%
% Now we plot one row of above image to get a better visual for
% the noise.

figure;
plot(imgMean(end/2,:)); 
title('Original Noise');
ylabel('Brightness');
xlabel('Column');

%%
% C.4 We now extract only every other column from a single row to consider
% only one color channel, which makes a smoother plot.

plot(imgMean(end/2,1:2:end), 'g');
ylabel('Brightness');
xlabel('Column');
title('Noise from single color channel');
hold on;
%% 
% C.5-6 We want plot the mean plus and minus the standard deviation on the
% same canvas as the original (shown in green).

hold on;
plot(imgMean(end/2,1:2:end) + imgStdDev(end/2,1:2:end));
title('Original Noise +- Standard Deviation');
%C.9-10

plot(imgMean(end/2,1:2:end) - imgStdDev(end/2,1:2:end));
axis tight;

%% 
% C.11 We examined the noise by multiplying Std. Dev. by 2 and then
% multiplying by 256 to examine the span of grey levels. The noise appears
% to span on average 6 gray levels in this particular instance.

noise = imgStdDev .* 2 .* 256;

%% 
% C.12 We used the mean function to cakculate average noise of image across
% all pixles. An estimate of the average noise for all pixels is 13.0574.

mean1 = mean(noise);
mean2 = mean(ans);



%% 
% C.13 Finally, we used 'max' to calculate the worst case of noise in the image.
% An estimate of the worst case noise is 69.7
maximum1= max(noise);
maximum2 =max(ans);

%% Conclusion
% In this lab we explored the baisics of image processing as well as an
% approach for analyzing the noise of greyscale images, given a set of
% similar images. We saw how to calculate the standard deviation of a set
% of images, and we hypothesized that areas of greatest brightness seem to
% yield the most noise. The noise in our set of images seemed relativily
% low, on average traversing 13 grey levels, and our maximum noise was
% around 70. 

%% Acknowlegements
% All image data taken from Jerod Weinman, location : 
% /home/weinman/courses/CSC262/images/raw.
%
% FIN 