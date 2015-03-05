%% Feature Detection
% Authors: Kevin Lee (Box 4088) and Renn Jervis (Box 3762)
% CSC 262  
%% Introduction
% In this lab we explore the process of detecting features or keypoints in
% an image at a particular scale. We will develop an algorithm for the
% detection of well-localized features using Gaussians and Gaussian
% derivatives. We also exploit the use of thresholds in order to create
% repeatability when analyzing images taken from differing angles.

%% Filtering for Detection
% We want to consider only well-localized features in the image that are
% unique. We begin by creating our Gaussian filters, one with a variance of
% 1 which will be used to compute the partial derivtives of the image, and
% the other with a variance of 1.5^2 to average our feature responses by
% smoothing. We begin with the familiar cameraman image as shown below, and
% compute its partial derivatives via separable filters by convolving the
% Gaussian and its derivative across first the rows and then the columns of
% the image. Then we square the partials in each direction and blur them
% with the larger Gaussian kernel to average the image. Finally, we
% calculate the product of the partials (IxIy) and blur this as well.

img = im2double(imread('cameraman.tif'));
figure;
imshow(img);
title('Original Cameraman Image');

%% 
% Arranging the squared partials and the directional derivative, we get the
% following conceptual matrix A, where Ix represents the partial derivative
% across the rows and Iy the derivative across the columns.
figure;
imshow(imread('/home/jervisre/262Vision/final.jpg'));
title('Theoretical Matrix of Partial Derivates');

% Create Gaussian and Gaussian derivative as separable filters to create
% partial derivatives
gauss = gkern(1);
gaussder = gkern(1, 1);
gaussblur = gkern(1.5^2);% Gaussian with larger variance for blurring

% Create partial derivs along rows and columns
rowderiv = conv2(gauss, gaussder, img, 'same');
colderiv = conv2(gaussder, gauss, img, 'same');
rowsquare = rowderiv.^2 ;
colsquare = colderiv.^2;
rowblur = conv2(gaussblur, gaussblur, rowsquare, 'same');
colblur =  conv2(gaussblur, gaussblur, colsquare, 'same');

derivProduct = rowderiv .* colderiv; % calculate product of partials
% blur product of partials
productblur = conv2(gaussblur, gaussblur, derivProduct, 'same');
 
 
 %% Calculating Feature Strength
 % We will now attempt to detect significant features in the image
 % utilizing the quantities in the matrix above. We will calculate the
 % determinant and trace of the matrix, and then examine the ratio of these
 % to determine the areas in the image where features are the strongest.
 % The determinant image is shown below.
 
pixeldet = rowblur .* colblur - productblur .^ 2; % ad-bc of matrix A
figure;
imshow(pixeldet, []);
colormap(jet);
colorbar;
title('Determinant of Feature Matrix Image');
%%
% The determinant of our matrix is Ix^2 * Iy^2 - (IxIy)^2, or difference
% between the product of the squared partial derivatives and the square of
% the product of the partial derivatives. It therefore makes sense that we
% will see a strong responce where both partial derivatives are large
% because we average the partials after squaring in the first term, and
% square the average of the product of the partial in the second term. This
% has two effects, it not only highlights where there are large partials,
% but it also returns significantly larger values where both partials are
% large. The determinate therefore represents the uncertainty of the
% localization of our features. We can also explain the determinant as the
% product of the eigenvales of the feature, which lends intuition as to why
% we see strong responses for features which are well localized. We
% therefore see features emerge in the image along edges in both horozontal
% and vertical directions, and our strongest responses occur at locations
% where there are edges in both directions (corners). For example, consider
% the bands on the legs of the camera, which are horozontal stripes of
% white bounded by the vertical dark edges of the leg. Similarly, consider
% the point in in the middle of the image, at the top of the central tripod
% base shaft, where the dark shadow of the camera and the light tripod
% shaft intersect.

%%
% Next we will consider the trace of the image, which is the sum of the
% squared partial derivatives.

pixeltrace = rowblur + colblur;
figure;
imshow(pixeltrace, []);
colormap(jet);
colorbar
title('Trace of Feature Matrix Image');
%%
% The trace is the sum of the squared partial derivatives of the image, and
% so gives the strongest responses at edges in the image. This is to be
% expected, as the trace of our matrix A is in fact equal to the magnitude
% of the gradient squared. We may also explain the trace of our matrix as
% the sum of the eigenvalues. This means that the trace will produce larger
% responces when we have large eigenvalues, which is another explanation
% for why it detects edges. We see in the trace image the cameraman
% outlined in a strong silhouette and the legs of the camera outlined as
% well. We note that the trace does not preserve very many details in the
% background edges or the interior of the coat. This is because these
% regions exhibit changes in pixel intensity which are not very notable,
% and so the partial derivative responses are small.

%%
% Finally, we consider the ratio of the trace to the determinant.
pixelratio = pixeldet ./ pixeltrace;
figure;
imshow(pixelratio, []);
colormap(jet);
colorbar;
title('Feature Strength Image');
%%
% In the ratio image, we see responses similar to that of the determinate, 
% because this operation also responds to features where both eigenvalues
% are large. For example, we again see strong responses at the bands on the
% legs of the camera, and at the top of the central tripod shaft. This
% makes sense because the ratio of the determinant to the trace is the
% ratio of the product of the eigenvalues over their sum, which we know
% maximizes responses where both eigenvalues are large.

%% Finalizing Feature Detection
% Simply considering the ratio of the determinant to the trace gives us an
% idea where the strong features are in the image, but we need a method to
% refine the locations of the features we want to consider. Because we wish
% to mark features which are especially well-localized, we accomplish this
% by first determining extracting the local maxima in the ratio image. We
% then apply an appropriately small threshold to the ratio image to
% eliminate weak responses and create another binary image. Finally, since
% we want to only consider the features which appear in both of these cases
% (ie are both local maxima and above the threshold) we may take the
% product of the two binary images, which returns a matrix containing the
% locations of features as indicated by nonzero entries.
maxImg = maxima(pixelratio);
thresholded = pixelratio > .0025;
maxThresh = maxImg .* thresholded;
figure; imshow(maxThresh, []); 
title('Well-Localized & Thresholded Maxima Features of Cameraman');

%% Making a Detection Function
% We want to generalize our above approach to apply it to several images, 
% and so we create a function which consolidates all of the above steps.


%% Estimating repeatability
% In an attempt to examine the reliability of our detection function,
% we will now consider two images of the same scene taken from slightly
% different points of view and compare the results of our detection between
% them. The two images and their detected features are shown below.

img1 = im2double(imread('/home/weinman/courses/CSC262/images/kpdet1.tif'));
img2 = im2double(imread('/home/weinman/courses/CSC262/images/kpdet2.tif'));
% apply function to new images
imgLogic1= kpdet(img1);
imgLogic2= kpdet(img2);
% extract the locations of the features detected
[rows1, cols1] = find(imgLogic1 == 1);
[rows2, cols2] = find(imgLogic2 == 1);

figure;
imshow(img1);
hold on;
plot(cols1, rows1, 'r+'); % plot detected features on top of orig image
title('Feature Detection Image 1');
figure;
imshow(img2);
hold on;
plot(cols2, rows2, 'r+'); % plot detected features on top of orig image
title('Feature Detection Image 2');
%%
% The features detected are, in general, corners which are well localized.
% Since the two pictures were taken at different angles, some features may
% not be correctly located again. In general, the repeatability of the
% function is fairly good. For instance, the very lower corner of the
% bottom stone wall is detected in both images, but the foreign floating
% object is only detected in the second image. This is most likely due to
% the shallow angle at which the picture was taken. Unfortunately, there
% are some regions where false positives appear or a high density of
% responses that do not necessarily correspond to appropriately localized
% features emerge. If however, we raise our threshold to lower the number
% of false positives, we lose many of the important responses.

%% Extra
% We can modify our kpdet function so that it returns not only the
% locations of our detected features, but also the gradient orientations at
% each of these figures.

%% Conclusion
% In this lab, we developed intuition as to how the eigenvalues associated
% with a feature can be used to locate key features in an image. We also
% saw how partial derivaties govern our detection of corners, and developed
% an algorithm for such feature detection using these principles. Finally,
% to verify our approach we also consider its repeatability, which is very
% important for feature matching across images.


%% Acknowlegements
% The cameraman image was loaded from the MATLAB library, and the kpdet
% images are courtesy of Jerod Wienmann and  licensed under a Creative 
% Commons Attribution-Noncommercial-Share Alike 4.0 International License.
% The image of the matrix A was taken from 
% http://en.wikipedia.org/wiki/Corner_detection and modified by Renn Jervis
% on 3/3/15.
% Code snippets taken from Feature Detection lab:
% http://www.cs.grinnell.edu/~weinman/courses/CSC262/2015S/labs/