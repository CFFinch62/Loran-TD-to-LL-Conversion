#ifndef RADNAV_H
#define RADNAV_H

#include <stdio.h>
#include <stdlib.h>




#define UP                  1
#define DOWN                0
#define ON   1
#define OFF  0
/* Important Navigation Parameters*/


#define PI 3.141592654
#define ETA1 1.000338 /*USCG Atmospheric refractive index at surface of Earth*/
#define VC 2.99792458e8F  /*Speed of light in vaccuum*/
#define VA 2.996911624e8F /*velocity in air - primary velocity - USCG/NIMA(DMA) metres/sec*/
#define MU0 PI*4e-7
#define EPSILON1 1.000676 /*permittivity of air at surface of Earth*/
#define EPSILON2 15 /*Permittivity if surface of Earth 15 for now */
#define EPSILON 8.854185e-12F
#define ALPHA 0.75
#define RADIUS 6.36739e6F  /*radius of the Earth - replace 'a' in equations*/

#define IN_BOUNDS 1
#define OUT_OF_BOUNDS 0
#define POSITIVE            1
#define NEGATIVE           -1


#endif
