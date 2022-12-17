# MI01-Image-Contour-detector
## A small course project that reveals the contours of an image

### Introduction  :
Here is a course project (UTC) done in the uv [MI01](https://moodle.utc.fr/course/view.php?id=1151), an introduction to the structure of computers 🔧💻. 
The idea of the project is to design a program in **assembler** allowing the detection of the **contours of an image**. The developed algorithm uses the sobel filter, an operator allowing the processing of an image to reveal its contours.

The processed images are 32-bit **color images** 📸. Each pixel is represented by an unsigned integer expressed in **32 bits** that contains the values of red (🔴), green (🟢), blue (🔵) and transparency (α). The value of each color component is an integer between 0 and 255 and is expressed in one byte.

### Step one : gray level
The detection of the contours of a color image requires a first step which consists in calculating the intensity of each pixel. The idea is to transform the image into [gray level](https://fr.wikipedia.org/wiki/Niveau_de_gris). 
To do this, we multiply each component of the pixel by integer coefficients that match the human vision. In this way, the image is converted into black and white without losing its initial data.

### Second step : Sobel filter
After converting the image to gray level, we need to process the image data with the [sobel filter](https://fr.wikipedia.org/wiki/Filtre_de_Sobel) method. To do this, we need to set up a matrix walk of the image in 9x9 blocks to calculate the gradient of the image using two convolution masks.
