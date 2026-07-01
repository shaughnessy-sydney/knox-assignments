//blurs an image using CUDA
//CS 214 2025

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "ppmFile.c"


//blur function


__global__ void kernel(int width, int height, unsigned char *d_input, unsigned char* d_output){

    int sumR = 0;
    int sumG = 0;
    int sumB = 0;
    int divcount = 0;

    //get location
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    ////////////////horizontal blurring pixels
    
  
    if(i > 0){
        //add vals to sum
        sumR = sumR + d_input[(j * width + i-1) * 3 + 0];  //0 is red channel
        sumG = sumG + d_input[(j * width + i-1) * 3 + 1];  //1 is green channel
        sumB = sumB + d_input[(j * width + i-1) * 3 + 2];  //2 is blue channel
        divcount = divcount + 1;
    }

    if(i < width-1){
        //add vals to sum
        sumR = sumR + d_input[(j * width + i+1) * 3 + 0];  //0 is red channel
        sumG = sumG + d_input[(j * width + i+1) * 3 + 1];  //1 is green channel
        sumB = sumB + d_input[(j * width + i+1) * 3 + 2];  //2 is blue channel
        divcount = divcount + 1;
    }

   ////////// //vertical blurring pixels
    if(j < height-1){
        //add vals to sum
        sumR = sumR + d_input[((j+1) * width + i) * 3 + 0];  //0 is red channel
        sumG = sumG + d_input[((j+1) * width + i) * 3 + 1];  //1 is green channel
        sumB = sumB + d_input[((j+1) * width + i) * 3 + 2];  //2 is blue channel
        divcount = divcount + 1;
    }

    if(j > 0){
        //add vals to sum
        sumR = sumR + d_input[((j-1) * width + i) * 3 + 0];  //0 is red channel
        sumG = sumG + d_input[((j-1) * width + i) * 3 + 1];  //1 is green channel
        sumB = sumB + d_input[((j-1) * width + i) * 3 + 2];  //2 is blue channel
        divcount = divcount + 1;
    }

    //////////corner pixels
    // j-1, i-1
    if(i > 0 && j > 0){
        //add vals to sum
        sumR = sumR + d_input[((j-1) * width + i-1) * 3 + 0];  //0 is red channel
        sumG = sumG + d_input[((j-1) * width + i-1) * 3 + 1];  //1 is green channel
        sumB = sumB + d_input[((j-1) * width + i-1) * 3 + 2];  //2 is blue channel
        divcount = divcount + 1;
    }

    // j-1, i+1
    if(j > 0 && i < width-1){
        //add vals to sum
        sumR = sumR + d_input[((j-1) * width + i+1) * 3 + 0];  //0 is red channel
        sumG = sumG + d_input[((j-1) * width + i+1) * 3 + 1];  //1 is green channel
        sumB = sumB + d_input[((j-1) * width + i+1) * 3 + 2];  //2 is blue channel
        divcount = divcount + 1;
    }

    // j+1, i-1
    if(j < height-1 && i > 0){
        //add vals to sum
        sumR = sumR + d_input[((j+1) * width + i-1) * 3 + 0];  //0 is red channel
        sumG = sumG + d_input[((j+1) * width + i-1) * 3 + 1];  //1 is green channel
        sumB = sumB + d_input[((j+1) * width + i-1) * 3 + 2];  //2 is blue channel
        divcount = divcount + 1;
    }

    //j+1, i+1
    if(j < height-1 && i < width-1){
        //add vals to sum
        sumR = sumR + d_input[((j+1) * width + i) * 3 + 0];  //0 is red channel
        sumG = sumG + d_input[((j+1) * width + i) * 3 + 1];  //1 is green channel
        sumB = sumB + d_input[((j+1) * width + i) * 3 + 2];  //2 is blue channel
        divcount = divcount + 1;
    }

    int offset;  //index in array corresponding to a pixel

    if(i >=0 && i < width && j >=0 && j < height) {

          offset = (j * width + i) * 3 + 0;  //0 is red channel
          d_output[offset] = sumR/divcount;

          offset = (j * width + i) * 3 + 1;  //1 is green channel
          d_output[offset] = sumG/divcount;
       
          offset = (j * width + i) * 3 + 2;  //2 is blue channel
          d_output[offset] = sumB/divcount;
        
    }
}



int main (int argc, char *argv[]){
    const char* inFile = "640x426.ppm";     //file names for input and output files
    const char* outFile = "out.ppm";

    int width;                              //image size
    int height;
    Image *inImage, *outImage;              //image structs (defined in ppmFile.h)
    unsigned char *data;                    //input image data

    //Device variables:
    unsigned char *d_input;                 //input image data
    unsigned char *d_output;                //output image data

    inImage = ImageRead(inFile);            //get input image and its attributes  
    width = inImage->width;
    height = inImage->height;
    data = inImage->data;
    int image_size = width * height * 3;    //size of image in byes; 3 is # channels

    //allocate memory for GPU
    cudaMalloc((void**)&d_input, sizeof(unsigned char*) * image_size);
    cudaMalloc((void**)&d_output, sizeof(unsigned char*) * image_size);

    //copy values to GPU
    cudaMemcpy(d_input, data, image_size, cudaMemcpyHostToDevice);

    //call kernel using block size 32x32
    dim3 blockD(32,32);
    dim3 gridD((width + blockD.x - 1)/blockD.x, (height + blockD.y - 1)/blockD.y);
    kernel<<<gridD, blockD>>>(width, height, d_input,d_output);
    
    //create and clear image variable for use as the result
    outImage = ImageCreate(width,height);
    ImageClear(outImage,255,255,255);
    
    cudaDeviceSynchronize();

    //copy output image from gpu
    cudaMemcpy(outImage->data, d_output, image_size, cudaMemcpyDeviceToHost);

    ImageWrite(outImage, outFile);        //write output image to file

    free(inImage->data);                  //free memory
    free(outImage->data);

    return 0;
}
