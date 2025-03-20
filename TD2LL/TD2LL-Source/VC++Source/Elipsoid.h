// Ellipsoid.h: interface for the Ellipsoid class.
//
//////////////////////////////////////////////////////////////////////



#if !defined(AFX_Ellipsoid_H__74136B21_DF6C_11D6_842B_00105CAB078C__INCLUDED_)
#define AFX_Ellipsoid_H__74136B21_DF6C_11D6_842B_00105CAB078C__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000


#define PI 3.141592654

class Ellipsoid  
{
public:
	void SetSpherical(double initRadius);
	double MeanRadiusCurvature(double initLatitude);
	double CalculateRadiusN(double initLatitude);
	double CalculateRadiusM(double initLatitude);

	
	
	Ellipsoid();
	virtual ~Ellipsoid();
	void SetParameters(CString initName);

	// inline functions

	inline double GetE2(void) {return E2;}
	inline double GetN(void) {return N;}
	inline double GetM(void) {return M;}
	inline double GetF(void) {return F;}
	inline double GetA(void) {return A;}
	inline double GetB(void) {return B;}

private:
	double N;
	double M;
	double A;
	double B;
	double E2;
	double F;

};

#endif // !defined(AFX_Ellipsoid_H__74136B21_DF6C_11D6_842B_00105CAB078C__INCLUDED_)
