// LoranTransmitter.cpp: implementation of the CLoranTransmitter class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"

#include "LoranTransmitter.h"
#include "MapPoint.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CLoranTransmitter::CLoranTransmitter(CString initName, MapPoint initPosition, double initEmissionDelay, char initDesignator)
{
	//Initialise some stuff
	cDesignator = initDesignator;
	iEmissionDelay=initEmissionDelay;
	Position = initPosition;
	strName=initName;
}

CLoranTransmitter::CLoranTransmitter()
{
	//Initialise some stuff
	cDesignator = ' ';
	iEmissionDelay=0.0;
	Position.SetPoint(0,0,0,0);
	
	strName="";
}

CLoranTransmitter::~CLoranTransmitter()
{

}


void CLoranTransmitter::SetPosition(MapPoint initPosition)
{
	Position = initPosition;

}



void CLoranTransmitter::SetDesignator(char initDesignator)
{
	cDesignator =initDesignator;
}

void CLoranTransmitter::SetEmissionDelay(double initEmissionDelay)
{
	iEmissionDelay = initEmissionDelay;
}



