// MapPoint.h: interface for the MapPoint class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_MAPPOINT_H__74136B23_DF6C_11D6_842B_00105CAB078C__INCLUDED_)
#define AFX_MAPPOINT_H__74136B23_DF6C_11D6_842B_00105CAB078C__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "ecef.h"
#include "Elipsoid.h"


class MapPoint  
{
	Ellipsoid Elip;
	double Latitude;
	double Longitude;
	double Height;


public:
	void ToGeographic2(double initPhi);
	int m_RadFlag;
	void ToGeographic();
	void ToECEF(void);
	ECEF GetECEF(void);
	void ToDegrees(void);
	void ToRadians(void);
	void SetPoint(double initLatitude, double initLongitude, double initHeight, Ellipsoid *initElip);
	
	double operator-(MapPoint);
	double operator/(MapPoint);
	int operator==(MapPoint);

	MapPoint(void);
	MapPoint(double initLatitude, double initLongitude, double initHeight, Ellipsoid *initElip);
	virtual ~MapPoint();

	//inline functions here 

	inline double GetLatitude(void){return Latitude;}
	inline double GetLongitude(void){return Longitude;}
	inline void SetLatitude(double initLat){Latitude = initLat;}
	inline void SetLongitude(double initLon){Longitude = initLon;}

	ECEF ecefCoords;


};

#endif // !defined(AFX_MAPPOINT_H__74136B23_DF6C_11D6_842B_00105CAB078C__INCLUDED_)
