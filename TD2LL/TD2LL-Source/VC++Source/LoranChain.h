// LoranChain.h: interface for the CLoranChain class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_LORANCHAIN_H__EA00FB02_0989_11D5_9D8F_00105CAB078C__INCLUDED_)
#define AFX_LORANCHAIN_H__EA00FB02_0989_11D5_9D8F_00105CAB078C__INCLUDED_

#include "LoranTransmitter.h"	// Added by ClassView
#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "loran.h"
#include "MapPoint.h"


class CLoranChain  
{
public:
	CLoranTransmitter* GetTransmitter(int iTX);
	inline int GetTXCount() { return(iTXCount); }
	void SetTransmitter(CString name, MapPoint position, double ED, char designator);
	CString GetGRI() {return(GRI);}

	void SetGRI(CString initGRI);

	void SetName(CString initName);
	CString GetName(void);

	CLoranChain(CString initGRI);
	CLoranChain(); //default constructor
	
	virtual ~CLoranChain();

private:
	int iTXCount;
	CLoranTransmitter **Group;
	CString GRI;
	CString strName;
};

#endif // !defined(AFX_LORANCHAIN_H__EA00FB02_0989_11D5_9D8F_00105CAB078C__INCLUDED_)
