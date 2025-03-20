// LoranChain.cpp: implementation of the CLoranChain class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
//#include "NavGather.h"
#include "LoranChain.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CLoranChain::CLoranChain(CString initGRI)
{
	GRI = initGRI;
	iTXCount=0;
	Group = (CLoranTransmitter**)new CLoranTransmitter*[MAX_TRANSMITTERS];

}

CLoranChain::CLoranChain()
{
	GRI = "";
	iTXCount=0;
}

CLoranChain::~CLoranChain()
{
int i;

for(i=0;i<iTXCount;++i)
	{
	delete Group[i];
	}

	delete [] Group;
}

void CLoranChain::SetGRI(CString initGRI)
{
	GRI = initGRI;
}


void CLoranChain::SetName(CString initName)
{
	strName = initName;
}

CString CLoranChain::GetName()
{
	return(strName);
}

void CLoranChain::SetTransmitter(CString name, MapPoint position, double ED, char designator)
{

	int tst;
	
	tst = iTXCount;
	Group[iTXCount] = new CLoranTransmitter(name, position, ED, designator);
	
	iTXCount++;

}



CLoranTransmitter* CLoranChain::GetTransmitter(int iTX)
{

	return Group[iTX];

}
