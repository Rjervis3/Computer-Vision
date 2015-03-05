%% Image Filtering
% Eleanor Tursman (4719),
% Renn Jervis (3762)
%
% CSC 262

load mandrill
X = im2double(ind2gray(X,map));
clear map; 

boxcar = ones(1,10);
boxcar = boxcar ./10;
boxfilter = boxcar' * boxcar;

gauss = gkern(10);
sum(gauss); % should be equal to 1 if normalized

gaussFilter=gauss' * gauss; % create 2d gauss filter
sum1=sum(gaussFilter);
sum2 = sum(sum1); % should be 1 if normalized

%show 3d plot of kernel
surf(gaussFilter);

% Display as image
imshow(gaussFilter,  []);

filter1 = conv2(boxcar, boxcar, X, 'same'); 
imshow(filter1);
%B.2 In examinin the image we notice the border or darker pixels
% image is lighter overall, contrast is lost. visible under the eyes and
% around the nose of the mandrill
% whiskers widened and made transparent - ghost image 

 filter2 = conv2(gauss, gauss, X, 'same');
 imshow(filter2);
%B.4 less gosting in image, small structures retain original shapes

%B.5 The gauss filter seems to be a better blur filter. Small high contrast
% details such as whiskers are better maintained in the gaussian filtered
% image. The gauss also has fewer artifacts in general.

 tic;  image1 = conv2(gauss, gauss, X, 'same'); toc;
 tic; image2 = conv2(X, gaussFilter, 'same'); toc;
 
 %  separable = 0.011381 seconds , block = 0.024267 seconds
 % The separable filter is about twice as fast as the 2D gaussian kernel.
 % The percent difference between the two times is approximately 72%
 
legal = imread('/home/weinman/courses/CSC262/images/legal.png');
legal = im2double(legal);


legal2 = imcomplement(legal);


 template = imread('template.png');
 template = 2*template - 1;
 template = im2double(template);
 
 %template = 2*template - 1;
 
 result = filter2(template,legal2,'same'); 
 