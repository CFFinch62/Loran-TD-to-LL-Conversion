// TD_CONV.CPP

#include "stdafx.h"
#include "TD2LL.h"
#include "TD2LLDlg.h"
#include "common.h"
#include "mutils.h"
#include <math.h>
#include <direct.h>
#include "registerpopup.h"
#include "available.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#define ITER 1
#define NONITER 0

void CTD2LLDlg::LL2TD( double lat1, double lon1, Ellipsoid *wgs84, double &dbltd1, double &dbltd2)
{
	MapPoint position;
	double mdistance, sec1distance,sec2distance;

	//m_MPSecondary1.ToECEF();
	//m_MPSecondary2.ToECEF();
	//m_MPMaster.ToECEF();

			
	position.SetPoint(lat1,lon1,0,wgs84);  

	AdjustForSF(); //just used for ASF this time

	//if(m_Method==ITER)
		//{
		mdistance = position-m_MPMaster;
		sec1distance = position-m_MPSecondary1;
		sec2distance = position-m_MPSecondary2;
		//}


     mdistance = 1E6*mdistance/VA + GetSeaWaterDelay(mdistance);
     sec1distance = 1E6*sec1distance/VA + GetSeaWaterDelay(sec1distance) + m_ED1;
     sec2distance = 1E6*sec2distance/VA + GetSeaWaterDelay(sec2distance) + m_ED2;

     dbltd1 = sec1distance-mdistance+m_TD1ASF;
     dbltd2 = sec2distance-mdistance+m_TD2ASF;
	
}

void CTD2LLDlg::TD2LL( double td1, double td2, MapPoint &ship)
{
	m_dblTD1 = td1;
	m_dblTD2 = td2;

double opt1;
double opt2;
//double angle1;
//double angle2;
double radius;
static int stored=0;

matrix A;
vector b;
vector answer;
int i;

	A = (double**)malloc(sizeof(double*) * 3);

	for(i=0;i<3;++i)
		A[i] = (double*)malloc(sizeof(double) * 3);

	b = (double*)malloc(sizeof(double)*3);
	answer = (double*)malloc(sizeof(double)*3);


	//go through once to get approximate location
	//then go through a second time to include Secondary Factor

	m_TD1SF=0;
	m_TD2SF=0;

	m_TD1ASF=0;
	m_TD2ASF=0;


	//need to do this on each press because user may change conversion mode

	StoreTXInfo();

	ComputeSphereOriginOffset(); //recompute
	ConvertToSphere(&m_MPMaster);  //do datum transformation
	ConvertToSphere(&m_MPSecondary1);
	ConvertToSphere(&m_MPSecondary2);
	

	//Compute ECEF coordinates wrt sphere 

	m_MPMaster.ToECEF();  
	m_MPSecondary1.ToECEF();
	m_MPSecondary2.ToECEF();

	for(i=0;i<2;++i)
		{
		CalculateP();   // calculate P array
		ComputeThetas();
		CalculateAArray();
		CalculateUArray();
		CalculateCosBetaX(&opt1, &opt2);

		m_CosBetaX = opt1;

		if(m_Amb==TRUE)
			{
			m_CosBetaX = opt2;
			}

		m_ThetaMRX = atan2( (cos(m_P[0])-cos(m_ThetaMSec1)),(sin(m_P[0])+sin(m_ThetaMSec1)*m_CosBetaX));
		m_ThetaSec1RX = m_ThetaMRX+m_P[0];
		m_ThetaSec2RX = m_ThetaMRX+m_P[1];  

		if(i==0)
			AdjustForSF();  //compute SF at the approximate ranges and include ASF here too
		}


	A[0][0] = m_MPSecondary1.ecefCoords.GetX();
	A[0][1] = m_MPSecondary1.ecefCoords.GetY();
	A[0][2] = m_MPSecondary1.ecefCoords.GetZ();
	A[1][0] = m_MPSecondary2.ecefCoords.GetX();
	A[1][1] = m_MPSecondary2.ecefCoords.GetY();
	A[1][2] = m_MPSecondary2.ecefCoords.GetZ();
	A[2][0] = m_MPMaster.ecefCoords.GetX();
	A[2][1] = m_MPMaster.ecefCoords.GetY();
	A[2][2] = m_MPMaster.ecefCoords.GetZ();

	radius = sphere->GetA(); //get sphere's radius

	b[0] = radius*radius*cos(m_ThetaSec1RX);
	b[1] = radius*radius*cos(m_ThetaSec2RX);
	b[2] = radius*radius*cos(m_ThetaMRX);

	InvertMatrix(A,3);
	MatrixByVector(A, b, answer,3,3);
	
	ship.ecefCoords.SetX(answer[0]);
	ship.ecefCoords.SetY(answer[1]);
	ship.ecefCoords.SetZ(answer[2]);

#ifdef HEIGHT
	ship.ToGeographic(); 
#endif
	
	ConvertToEllipsoid(&ship);

   free (b);
   free (answer);
   
   for(i=0;i<3;++i)
		free( A[i]);
   free( A);

}


void CTD2LLDlg::TD2LL2( double td1, double td2, MapPoint &estimate)
{
	m_dblTD1 = td1;
	m_dblTD2 = td2;

	estimate.ToRadians();
   	   
	double master_distance;
	double sec1_distance;
	double sec2_distance;
	double master_azimuth;
	double sec1_azimuth;
	double sec2_azimuth;
	double x=10000.0,y=10000.0;
	double e_squared;
	double l1, m1,n1, l2,m2,n2;
	double d_lat, d_lon;
//	static int stored =0;

	StoreTXInfo();

	AdjustForSF();
	m_MPMaster.ToRadians();
	m_MPSecondary1.ToRadians();
	m_MPSecondary2.ToRadians();

	//enter estimate into lat and long edit boxes

	e_squared = wgs84->GetE2();

while(fabs(x)>1 || fabs(y)>1)
	{
	master_distance = m_MPMaster-estimate; /*in metres*/
	sec1_distance = m_MPSecondary1-estimate;
	sec2_distance = m_MPSecondary2-estimate;

	master_distance = 1E6*master_distance/VA + GetSeaWaterDelay(master_distance); /*in microseconds*/
	sec1_distance = 1E6*sec1_distance/VA + GetSeaWaterDelay(sec1_distance);
	sec2_distance = 1E6*sec2_distance/VA + GetSeaWaterDelay(sec2_distance);

	master_azimuth = estimate/m_MPMaster;  /*all azimuths measured clockwise from south*/
	sec1_azimuth = estimate/m_MPSecondary1;
	sec2_azimuth = estimate/m_MPSecondary2;

	/*first TD*/
	l1 = sin(sec1_azimuth)-sin(master_azimuth);
	m1 = cos(sec1_azimuth)-cos(master_azimuth);
	//n1 = (sec1_distance-master_distance-(m_dblTD1-(m_Sec1ASF-m_MASF))+m_ED1)*VA*1E-6;
	n1 = (sec1_distance-master_distance-(m_dblTD1-m_TD1ASF)+m_ED1)*VA*1E-6;

	/*second TD*/
	l2 = sin(sec2_azimuth)-sin(master_azimuth);
	m2 = cos(sec2_azimuth)-cos(master_azimuth);
	//n2 = (sec2_distance-master_distance-(m_dblTD2-(m_Sec1ASF-m_MASF))+m_ED2)*VA*1E-6;
	n2 = (sec2_distance-master_distance-(m_dblTD2-m_TD2ASF)+m_ED2)*VA*1E-6;

	x = (n2*m1-n1*m2)/(l1*m2-l2*m1);
	y = (n2*l1-n1*l2)/(m1*l2-m2*l1);


    d_lat = y*pow(sqrt(1-e_squared*pow(sin(estimate.GetLatitude()),2)),3)/(wgs84->GetA()*(1-e_squared));
	d_lon = x*sqrt(1-e_squared*pow(sin(estimate.GetLatitude()),2))/(wgs84->GetA()*cos(estimate.GetLatitude()));

	estimate.SetLatitude(estimate.GetLatitude()+ d_lat);
	estimate.SetLongitude(estimate.GetLongitude()+ d_lon);

   }

	estimate.ToDegrees();
}


void CTD2LLDlg::StoreTXInfo()
{

m_MPMaster = Chains[iSelectedChain]->GetTransmitter(0)->GetPosition();
m_MPSecondary1 = Chains[iSelectedChain]->GetTransmitter(iSelectedSec1)->GetPosition();
m_MPSecondary2 = Chains[iSelectedChain]->GetTransmitter(iSelectedSec2)->GetPosition();

m_ED1 = Chains[iSelectedChain]->GetTransmitter(iSelectedSec1)->GetEmissionDelay();
m_ED2 = Chains[iSelectedChain]->GetTransmitter(iSelectedSec2)->GetEmissionDelay();

m_NavChain = Chains[iSelectedChain]->GetGRI();
m_NavPair.SetAt(0, Chains[iSelectedChain]->GetTransmitter(iSelectedSec1)->GetDesignator());
m_NavPair.SetAt(1, Chains[iSelectedChain]->GetTransmitter(iSelectedSec2)->GetDesignator());




}


//this functions calculates angles based on TD values

void CTD2LLDlg::CalculateP()
{
	double radius;
	double term;

	radius = sphere->GetA();
	term = VA/radius;

	m_P[0] = term*(m_dblTD1-m_ED1-m_TD1ASF-m_TD1SF)/1E6;
	m_P[1] = term*(m_dblTD2-m_ED2-m_TD2ASF-m_TD2SF)/1E6;

}



void CTD2LLDlg::ComputeThetas()
{
//double b;
//double c;
//double a;
vector s1,s2,m;
double radius;

	radius = sphere->GetA();

	s1 = new double[3];
	s2 = new double[3];
	m = new double[3];

	//m_MPSecondary1.ToECEF();
	//m_MPSecondary2.ToECEF();
	//m_MPMaster.ToECEF();

	s1[0] = m_MPSecondary1.ecefCoords.GetX();
	s1[1] = m_MPSecondary1.ecefCoords.GetY();
	s1[2] = m_MPSecondary1.ecefCoords.GetZ();

	s2[0] = m_MPSecondary2.ecefCoords.GetX();
	s2[1] = m_MPSecondary2.ecefCoords.GetY();
	s2[2] = m_MPSecondary2.ecefCoords.GetZ();

	m[0] = m_MPMaster.ecefCoords.GetX();
	m[1] = m_MPMaster.ecefCoords.GetY();
	m[2] = m_MPMaster.ecefCoords.GetZ();

	
	m_ThetaMSec1 = acos(InnerProduct(m,s1,3)/(radius*radius));
	m_ThetaMSec2 = acos(InnerProduct(m,s2,3)/(radius*radius));
	m_ThetaSec1Sec2 = acos(InnerProduct(s1,s2,3)/(radius*radius));

	m_K = acos( (cos(m_ThetaSec1Sec2)-cos(m_ThetaMSec1)*cos(m_ThetaMSec2))/(sin(m_ThetaMSec1)*sin(m_ThetaMSec2)) );

	delete [] s1;
   delete [] s2;
   delete [] m;
}

void CTD2LLDlg::CalculateUArray()
{
	m_UArray[0] = m_AArray[0]*cos(m_K)-m_AArray[1];
	m_UArray[1] = m_AArray[0]*sin(m_K);
	m_UArray[2] = m_AArray[1]*(sin(m_P[0])/sin(m_ThetaMSec1))-m_AArray[0]*(sin(m_P[1])/sin(m_ThetaMSec2));
	
}

void CTD2LLDlg::CalculateAArray()
{

	m_AArray[0] = (cos(m_P[0]) - cos(m_ThetaMSec1))/sin(m_ThetaMSec1);
	m_AArray[1] = (cos(m_P[1]) - cos(m_ThetaMSec2))/sin(m_ThetaMSec2);


}

void CTD2LLDlg::CalculateCosBetaX(double *opt1, double *opt2)
{

*opt1 = (m_UArray[2]*m_UArray[0]+m_UArray[1]*
		sqrt(m_UArray[0]*m_UArray[0]+m_UArray[1]*m_UArray[1]-m_UArray[2]*m_UArray[2]))/
		(m_UArray[0]*m_UArray[0]+m_UArray[1]*m_UArray[1]);


*opt2 = (m_UArray[2]*m_UArray[0]-m_UArray[1]*
		sqrt(m_UArray[0]*m_UArray[0]+m_UArray[1]*m_UArray[1]-m_UArray[2]*m_UArray[2]))/
		(m_UArray[0]*m_UArray[0]+m_UArray[1]*m_UArray[1]);

}

//Using known angles and comverting to distances for lookup

void CTD2LLDlg::AdjustForSF()  // and ASF
{

	double distance;
	double radius;
//	double adjustment;
	double sf1;
	double sf2;
	double sf3;

		
	if(m_Method==NONITER)
		{
		radius = sphere->GetA();
	
		distance = m_ThetaMRX*radius;

		sf1 = GetSeaWaterDelay(distance);
	
		distance = m_ThetaSec1RX*radius;
	
		sf2 = GetSeaWaterDelay(distance);

		distance = m_ThetaSec2RX*radius;
	
		sf3 = GetSeaWaterDelay(distance);
	
		m_TD1SF = sf2-sf1;
		m_TD2SF = sf3-sf1;
		}
	
	if(m_strMASF.IsEmpty())  //TD ASF mode
		{
		m_TD1ASF = str2dbl(m_strSec1ASF);
		m_TD2ASF = str2dbl(m_strSec2ASF);
		m_Sec1ASF =0;   //We cannot determine a TOA ASF from a TD ASF
		m_Sec2ASF =0;
		m_MASF=0;
		}
	else
		{
		m_Sec1ASF = str2dbl(m_strSec1ASF);
		m_Sec2ASF = str2dbl(m_strSec2ASF);
		m_MASF = str2dbl(m_strMASF);
		m_TD1ASF =m_Sec1ASF-m_MASF;  //we can make a TD ASF from two TOA ASFs
		m_TD2ASF =m_Sec2ASF-m_MASF;
		}

	m_TD1ASF = -m_TD1ASF; // ASFs are applied as "corrections" not actual "values"
	m_TD2ASF = -m_TD2ASF;


}

double CTD2LLDlg::GetSeaWaterDelay(double initDistance)
{

double pterm;
//double mult;
//int i;
double T;

T = (1E6)*initDistance/VA;

		  pterm = 0.0;

		  /*for (i=3; i != -1; i--)
        	{
		     mult = pow(initDistance/500.0, (3 - i));  //500 m points
		     pterm += SeaCoeffs[3-i]*mult;
} */
		  if(initDistance>160000)
			{
			  pterm = (SeaCoeffsUpper[0]/T)+SeaCoeffsUpper[1]+SeaCoeffsUpper[2]*T;
			}
		  else
			{
			  pterm = (SeaCoeffsLower[0]/T)+SeaCoeffsLower[1]+SeaCoeffsLower[2]*T;
			}


return pterm;

}

void CTD2LLDlg::ConvertToSphere(MapPoint *initPoint)  //method to perform conversion - testing datum conversion first
{


	MapPoint wgs84Point;
	MapPoint spherePoint(0,0,0,sphere);
	
	wgs84Point = *initPoint;
	
	wgs84Point.ToECEF();

	spherePoint.ecefCoords.SetX(wgs84Point.ecefCoords.GetX()+m_ecefSphereOffset.GetX());
	spherePoint.ecefCoords.SetY(wgs84Point.ecefCoords.GetY()+m_ecefSphereOffset.GetY());
	spherePoint.ecefCoords.SetZ(wgs84Point.ecefCoords.GetZ()+m_ecefSphereOffset.GetZ());

	spherePoint.ToGeographic();


	*initPoint = spherePoint;

	
}


void CTD2LLDlg::ConvertToEllipsoid(MapPoint *initPoint)
{

	
	MapPoint wgs84Point(0,0,0,wgs84); //default is wgs84 anyway
	MapPoint spherePoint;
	
	spherePoint = *initPoint;

	//spherePoint.ToGeographic();
	//spherePoint.ToRadians();

	wgs84Point.ecefCoords.SetX(spherePoint.ecefCoords.GetX()-m_ecefSphereOffset.GetX());
	wgs84Point.ecefCoords.SetY(spherePoint.ecefCoords.GetY()-m_ecefSphereOffset.GetY());
	wgs84Point.ecefCoords.SetZ(spherePoint.ecefCoords.GetZ()-m_ecefSphereOffset.GetZ());
	
#ifdef HEIGHT
	wgs84Point.ToGeographic2(initPoint->GetLatitude());//(spherePoint.GetLatitude()); //convert to geographic co-ordinates
#else
	wgs84Point.ToGeographic();//(spherePoint.GetLatitude()); //convert to geographic co-ordinates
#endif

	*initPoint = wgs84Point;		
	
}



void CTD2LLDlg::ComputeSphereOriginOffset()
{
	
	ECEF ecefSphere;
	ECEF ecefWGS84;
	double lat0=53.0;
	double lon0=-4.0;
	double dblRadius;
	double x,y,z;

	m_MPSecondary1.ToECEF();
	m_MPSecondary2.ToECEF();
	m_MPMaster.ToECEF();

	//Compute average of station ECEF coordinates and use this as the tangent point
	x = (m_MPSecondary1.ecefCoords.GetX()+m_MPSecondary2.ecefCoords.GetX()+m_MPMaster.ecefCoords.GetX())/3.0;
	y = (m_MPSecondary1.ecefCoords.GetY()+m_MPSecondary2.ecefCoords.GetY()+m_MPMaster.ecefCoords.GetY())/3.0;
	z = (m_MPSecondary1.ecefCoords.GetZ()+m_MPSecondary2.ecefCoords.GetZ()+m_MPMaster.ecefCoords.GetZ())/3.0;

	//m_MPTangentPoint.SetPoint(53.0,-4.0,0,wgs84); //set the tangent point for the service area using the ECEF system computed above
	
	m_MPTangentPoint.ecefCoords.SetX(x);
	m_MPTangentPoint.ecefCoords.SetY(y);
	m_MPTangentPoint.ecefCoords.SetZ(z);  

	//First of all compute the Origin offset of the osculating sphere
	//from the wgs84 ellipsoid, using the tangent point 
	
	m_MPTangentPoint.ToGeographic();

	//m_MPTangentPoint.SetPoint(lat0,lon0,0,wgs84); //set the tangent point for the service area using the ECEF system computed above

	dblRadius = wgs84->MeanRadiusCurvature(m_MPTangentPoint.GetLatitude());  //radius of curvature at that point
	
	sphere->SetSpherical(dblRadius);

	ecefWGS84 = m_MPTangentPoint.GetECEF();

	//ecef values for a sphere, with A=B are computed as follows:
	m_MPTangentPoint.ToRadians();
	ecefSphere.SetX(dblRadius*cos(m_MPTangentPoint.GetLatitude())*cos(m_MPTangentPoint.GetLongitude())); //converted to
	ecefSphere.SetY(dblRadius*cos(m_MPTangentPoint.GetLatitude())*sin(m_MPTangentPoint.GetLongitude()));
	ecefSphere.SetZ(dblRadius*sin(m_MPTangentPoint.GetLatitude()));
	m_MPTangentPoint.ToDegrees();

	m_ecefSphereOffset.SetX(ecefSphere.GetX()-ecefWGS84.GetX());
	m_ecefSphereOffset.SetY(ecefSphere.GetY()-ecefWGS84.GetY());
	m_ecefSphereOffset.SetZ(ecefSphere.GetZ()-ecefWGS84.GetZ());

}

