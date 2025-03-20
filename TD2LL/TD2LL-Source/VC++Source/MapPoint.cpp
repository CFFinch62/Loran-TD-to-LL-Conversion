// MapPoint.cpp: implementation of the MapPoint class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "TD2LL.h"
#include "MapPoint.h"
#include <math.h>

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

MapPoint::MapPoint()
{

	Latitude =0;
	Longitude =0;
	Height = 0;

	m_RadFlag=0; //default to degrees

}

MapPoint::MapPoint(double initLatitude, double initLongitude, double initHeight, Ellipsoid *elip)
{

	Latitude =initLatitude;
	Longitude =initLongitude;
	Height = initHeight;

	Elip = *elip;

	m_RadFlag=0;
}

MapPoint::~MapPoint()
{

}



void MapPoint::SetPoint(double initLatitude, double initLongitude, double initHeight, Ellipsoid *elip)
{
	Latitude  = initLatitude;
	Longitude = initLongitude;
	Height = initHeight;

	if(elip!=NULL)
		{
		Elip = *elip;
		}	
}



void MapPoint::ToRadians()
{
	if(m_RadFlag==0)
		{
		Latitude = Latitude*PI/180.0;
		Longitude = Longitude*PI/180.0;
		m_RadFlag=1;
		}
}

void MapPoint::ToDegrees()
{
	if(m_RadFlag==1)
		{
		Latitude = Latitude*180.0/PI;
		Longitude = Longitude*180.0/PI;
		m_RadFlag=0;
		}
}



ECEF MapPoint::GetECEF()
{

ToECEF();
return ecefCoords;

}

void MapPoint::ToECEF()
{
double N;


	Elip.CalculateRadiusN(Latitude);
	N=Elip.GetN();
	
	if(m_RadFlag==0)
		{
		ToRadians();  //convert to radians before trig functions
		}

	ecefCoords.SetX((N+Height)*cos(Latitude)*cos(Longitude));
	ecefCoords.SetY((N+Height)*cos(Latitude)*sin(Longitude));
	ecefCoords.SetZ((N*(1-Elip.GetE2())+Height)*sin(Latitude));

	if(m_RadFlag==1)
		{
		ToDegrees();  //convert back to radians
		}
}


void MapPoint::ToGeographic()
{
double w;
double x,y,z;
double e2;

x = ecefCoords.GetX();
y = ecefCoords.GetY();
z = ecefCoords.GetZ();

w = sqrt(x*x+y*y);

Longitude = atan2(y,x);

e2 = Elip.GetE2();

Latitude = atan2(z,(w*(1-Elip.GetE2())));

m_RadFlag =1; //now in radians

ToDegrees();  //convert to degrees

}

void MapPoint::ToGeographic2(double initPhi)
{

double w;
double x,y,z;
double e2;
double phi2,lastPhi2;
double term1, term2, term3;
double height;

x = ecefCoords.GetX();
y = ecefCoords.GetY();
z = ecefCoords.GetZ();

w = sqrt(x*x+y*y);

Longitude = atan2(y,x);

e2 = Elip.GetE2();

phi2 = PI*initPhi/180.0;


	do
		{
		term1 = z/sin(phi2);
		term2 = Elip.GetA()*e2;
		term3 = sqrt(1-e2*pow(sin(phi2),2));

		lastPhi2 = phi2;
		phi2 = acos(w/(term1+(term2/term3)));
		} while(fabs(lastPhi2-phi2)>0.0000001);





//Latitude  = atan2(z,w*(1-e2));

Latitude = phi2;

height = (w/cos(Latitude))-Elip.GetA()/term3;

m_RadFlag =1; //now in radians

ToDegrees();  //convert to degrees



}



double MapPoint::operator-(MapPoint StopLocation)
{
double f,distance,bj,bk,h,g,lambda,c,m;
double costheta,sintheta,t1,t2,t3,t4,t5,theta;
MapPoint tx,rx;

tx = *this; //StartLocation;
rx = StopLocation;

if(fabs(tx.GetLatitude()-rx.GetLatitude()) <0.00001 && fabs(tx.GetLongitude()-rx.GetLongitude())<0.00001)
   return(0);

f = Elip.GetF();

//convert to radians incase not already done so

tx.ToRadians();
rx.ToRadians();

lambda = fabs(tx.GetLongitude()-rx.GetLongitude());

if(lambda>=PI)
   lambda = 2*PI - fabs(tx.GetLongitude()-rx.GetLongitude());

bj = atan(tan(tx.GetLatitude())*(1-f));
bk = atan(tan(rx.GetLatitude())*(1-f));

g = sin(bj)*sin(bk);
h = cos(bj)*cos(bk);

costheta = g + h*cos(lambda);
theta = acos(costheta);
sintheta = sqrt( pow(sin(lambda)*cos(bk),2) + pow(sin(bk)*cos(bj)- sin(bj)*cos(bk)*cos(lambda),2));

c=h*sin(lambda)/sintheta;

m = 1-c*c;

t1 = ((1+f+f*f)*theta)+g*((f+f*f)*sintheta - ((f*f/2.0)*theta*theta/sintheta));
t2 = m*(f*f*theta*theta*costheta/(2.0*sintheta) - ((f+f*f)*theta/2.0) - ((f+f*f)*sintheta*costheta/2.0));
t3 = g*g*(-f*f*sintheta*costheta/2.0);
t4 = m*m*(f*f*theta/16.0 + f*f*sintheta*costheta/16.0 - f*f*theta*theta*costheta/(2.0*sintheta) - f*f*sintheta*pow(costheta,3)/8.0);
t5 = g*m*(f*f*theta*theta/(2.0*sintheta) + f*f*sintheta*costheta*costheta/2.0);

distance = (Elip.GetB())*(t1+t2+t3+t4+t5);

return(distance);

}



/***************************************************************************
***/
/*	 GetAzimuth()															  */
/*																			  */
/* Returns the azimuth from South from the transmitter to receiver in
radians */
/*
*/
/***************************************************************************
***/
double MapPoint::operator/(MapPoint startlocation)
{
	double f,bj,bk,h,g,lambda,c,m;
	double costheta,sintheta,t1,t2,t3,t4,theta;
	double r;
	double cotalpha;
	MapPoint tx,rx;

	tx=*this;  //start location
	rx = startlocation;

	tx.ToRadians();
	rx.ToRadians();

	if(tx==rx)
		return(0);

	
	f= Elip.GetF(); // spheroidal flattening

	lambda = fabs(tx.GetLongitude()-rx.GetLongitude());

	if(lambda>=PI)
		lambda = 2*PI - fabs(tx.GetLongitude()-rx.GetLongitude());

	bj = atan(tan(tx.GetLatitude())*(1-f));
	bk = atan(tan(rx.GetLatitude())*(1-f));

	g = sin(bj)*sin(bk);
	h = cos(bj)*cos(bk);

	costheta = g + h*cos(lambda);
	theta = acos(costheta);
	sintheta = sqrt( pow(sin(lambda)*cos(bk),2) + pow(sin(bk)*cos(bj)-
sin(bj)*cos(bk)*cos(lambda),2));

	c=h*sin(lambda)/sintheta;

	m = 1-c*c;

	t1 = (f+pow(f,2))*theta;
	t2 = g*( -(pow(f,2)/2)*sintheta-(pow(f,2)*pow(theta,2)/sintheta));
	t3 = -(5*pow(f,2)/4)*theta + (pow(f,2)/4)*sintheta*costheta +
pow(f,2)*pow(theta,2)*costheta/sintheta;
	t4 = m*t3;

	r = c*(t1 + t2 + t4)+lambda;

	if(r!=0 && bk!=1) //avoid divide by zero
		cotalpha = (sin(bk)*cos(bj)-cos(r)*sin(bj)*cos(bk))/(sin(r)*cos(bk));
	else
		cotalpha = 0;
//if(cotalpha!=0)
//	cotalpha  = atan(1.0/cotalpha);

if(cotalpha==0 && (tx.GetLongitude()==rx.GetLongitude()))
	{
   if(tx.GetLongitude()>rx.GetLongitude())
      cotalpha = 0;
   else
   	cotalpha = PI;
   }

else if(cotalpha<0 && (tx.GetLongitude() < rx.GetLongitude()))       /*quadrant 1*/
	{
   if(tx.GetLongitude()==rx.GetLongitude())
   	cotalpha = 0;
   else
	   cotalpha = 2*PI + atan(1/cotalpha);
   }
else if(cotalpha>0 && (tx.GetLongitude() < rx.GetLongitude()) ) /*quadrant 2*/
	{
   if(cotalpha!=0)
   	 cotalpha =atan(1/cotalpha);

	cotalpha = PI + cotalpha;
   }
else if(cotalpha>0 && (tx.GetLongitude() > rx.GetLongitude()))  /*quadrant 3*/
	{
	cotalpha = PI - atan(1/cotalpha);
   }
else if(cotalpha<0 && (tx.GetLongitude() > rx.GetLongitude()))  /*quadrant 4*/
	{
   if(cotalpha!=0)
   	 cotalpha =atan(1/cotalpha);

   cotalpha = fabs(cotalpha);
   }

//	cotalpha=atan2(1,cotalpha); // AIW: Changed to see if there's a problem



	return(cotalpha);
}


int MapPoint::operator==(MapPoint point)
{
	MapPoint tx;
	MapPoint rx;

	tx=*this;
	rx = point;

	if(tx.GetLatitude()==rx.GetLatitude() && tx.GetLongitude()==rx.GetLongitude())
		return(1);
	else
		return(0);
}



