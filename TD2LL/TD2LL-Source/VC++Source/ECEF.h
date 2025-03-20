// ECEF.h: interface for the ECEF class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_ECEF_H__74136B24_DF6C_11D6_842B_00105CAB078C__INCLUDED_)
#define AFX_ECEF_H__74136B24_DF6C_11D6_842B_00105CAB078C__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

class ECEF  
{

	double X;
	double Y;
	double Z;

public:
	ECEF();
	virtual ~ECEF();

	void SetX(double initX) {X = initX;}
	void SetY(double initY) {Y = initY;}
	void SetZ(double initZ) {Z = initZ;}
	double GetX(void) {return X;}
	double GetY(void) {return Y;}
	double GetZ(void) {return Z;}


};

#endif // !defined(AFX_ECEF_H__74136B24_DF6C_11D6_842B_00105CAB078C__INCLUDED_)
