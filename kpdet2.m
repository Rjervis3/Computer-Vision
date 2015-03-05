function [ detectionImg ] = kpdet2( img )
% KPDET2 Returns a logical matrix the same size as the image containing the
% locations of image features and the gradient orientation at these points.
% Locations are found using the ratio of the trace to the determinant of
% the matrix A: [[Ix^2; IxIy]; [IxIy; Iy^2]]
%
% detectionImg = kpdet(img) where img is an image for feature detection and
% detectionImg is a matrix of the same size as the image where
% local maxima beyond a threshold (ie well localized features) contain the
% gradient orientation at that pixel.
%
% Authors
%   Kevin Lee (Box 4088) Renn Jervis (Box 3762) CSC 262
%
% Lab:
%  Feature Detection

% create Gaussian and Gaussian derivative as separable filters to create
% partial derivatives
gauss = gkern(1);
gaussder = gkern(1, 1);
gaussblur = gkern(4.5^2);% Gaussian with larger variance for blurring

% create partial derivs along rows and columns
rowderiv = conv2(gauss, gaussder, img, 'same');
colderiv = conv2(gaussder, gauss, img, 'same');
rowsquare = rowderiv.^2 ; % find sqaure of partials Ix^2, Iy^2
colsquare = colderiv.^2;
rowblur = conv2(gaussblur, gaussblur, rowsquare, 'same'); % blur again
colblur =  conv2(gaussblur, gaussblur, colsquare, 'same');


derivProduct = rowderiv .* colderiv;  % IxIy
% blur product image
productblur = conv2(gaussblur, gaussblur, derivProduct, 'same');
% determinant ab-bc  
pixeldet = rowblur .* colblur - productblur .^ 2; 
 % trace Ix^2 + Iy^2
pixeltrace = rowblur + colblur;

pixelratio = pixeldet ./ pixeltrace;

maxImg = maxima(pixelratio); %consider maxima in image
thresholded = pixelratio > .0025;%discard values under threshold
%find points that are maxima above the threshold
thresholdMax = maxImg .* thresholded;
% find gradient orientation at all points in image
orientation = atan2(colblur, rowblur);
% create matrix with gradient orientations at thresholded maxima points
% (points where features are detected)
detectionImg = thresholdMax .* orientation;

end

