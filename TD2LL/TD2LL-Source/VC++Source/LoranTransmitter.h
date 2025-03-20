// LoranTransmitter.h: interface for the CLoranTransmitter class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_LORANTRANSMITTER_H__EA00FB01_0989_11D5_9D8F_00105CAB078C__INCLUDED_)
#define AFX_LORANTRANSMITTER_H__EA00FB01_0989_11D5_9D8F_00105CAB078C__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "radnav2.h" //Header file for some defines
#include "MapPoint.h"

class CLoranTransmitter  
{
public:
	CString GetName() {	return strName;}

	inline char GetDesignator() { return cDesignator; }

	void SetEmissionDelay(double initEmissionDelay);
	void SetDesignator(char initDesignator);
	inline double GetEmissionDelay(){	return iEmissionDelay;}
	void SetPosition(MapPoint initPosition);
	inline MapPoint GetPosition(){	return (Position);}
	CLoranTransmitter(CString initName, MapPoint initPosition, double initEmissionDelay, char cDesignator);
	CLoranTransmitter(); //Defult constructor
	virtual ~CLoranTransmitter();

private:
	MapPoint Position;
	char cDesignator;
	double iEmissionDelay;
	CString strName;
};

#endif // !defined(AFX_LORANTRANSMITTER_H__EA00FB01_0989_11D5_9D8F_00105CAB078C__INCLUDED_)
