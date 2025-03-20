// Ellipsoid.cpp: implementation of the Ellipsoid class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "TD2LL.h"
#include "Elipsoid.h"

#include <math.h>

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

Ellipsoid::Ellipsoid()
{
	SetParameters("WGS84"); //default to WGS-84 Ellipsoid
}

void Ellipsoid::SetParameters(CString initName)
{
	if(initName == "WGS84")
		{
		A = 6378137.0;  /*WGS 84 Ellipsoid parameters as default*/
		B = 6356752.3141;
		}
	
	F = 1 - (B/A); //Ellipsoidal flattening
	E2 = 1-(pow(B,2)/pow(A,2));
}

void Ellipsoid::SetSpherical(double initRadius)
{

A = initRadius;
B = initRadius;

F = 0; //Ellipsoidal flattening
E2 = 0;

}


Ellipsoid::~Ellipsoid()
{

}


double Ellipsoid::CalculateRadiusM(double initLatitude)
{
	initLatitude = initLatitude*PI/180;
	M=A*(1-E2)/pow((1-E2*pow(sin(initLatitude),2) ),3.0/2.0);

	return(M);

}

double Ellipsoid::CalculateRadiusN(double initLatitude)
{
	initLatitude = initLatitude*PI/180;
	N=A/sqrt(1-E2*pow(sin(initLatitude),2));

	return(N);

}


double Ellipsoid::MeanRadiusCurvature(double initLatitude)
{
	CalculateRadiusM(initLatitude);
	CalculateRadiusN(initLatitude);
	return(sqrt(M*N));
}


