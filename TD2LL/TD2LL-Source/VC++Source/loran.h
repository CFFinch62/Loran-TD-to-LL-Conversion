/*************************************************************************/
/*                                                                       */
/* Loran.h: LoranLoranC header file                                      */
/*                                                                       */
/* Identity: LORAN/HEADER                                                */
/*                                                                       */
/*	Title: loran.h                                                        */
/*                                                                       */
/*	Author: Dr. Paul Williams                                             */
/*                                                                       */
/* Date: 1998/99                                                         */
/*                                                                       */
/* (C) COPYRIGHT UNIVERSITY OF WALES, BANGOR, 1998                       */
/*                                                                       */
/*                                                                       */
/*  Last Modified: 6/1/99                                                */
/*  Modification History                                                 */
/*                                                                       */
/*  Version No.		Modifier			Date			Change			Reason    */
/*                                                                       */
/*************************************************************************/

#ifndef LORAN_H
#define LORAN_H

#include <stdio.h>
#include <stdlib.h>
#include "radnav2.h"
/* Important Navigation Parameters*/

/*GRS80*/


//#define TRANS_INFO "d:\\navcode\\data\\LTrans.dat"
/*change for distribution*/

#define TRANS_INFO "c:\\radionav\\radnavdata\\loranc\\tx\\htrn.dat"
#define MAX_TRANSMITTERS 5
#define MAX_CHAINS 100
#define FREQUENCY 100000

#ifndef LAMBDA
#define LAMBDA VA/FREQUENCY
#endif

#define NUMBER_CONDS  9

/*test EDs*/
#define INITIAL_PHASE	    5.0     /*changes with frequency*/

#define ED_SEC1 14100
#define ED_SEC2 29500

#define NO_RECORD 0
#define RECORD_FOUND 1
#define END_OF_FILE 2


typedef struct {
char name[20];
MapPoint position;
int ED;
char designator;
}Transmitter;

typedef struct {
char GRI[5];
Transmitter tx[MAX_TRANSMITTERS];
}chaininfo;

typedef struct {
	int SNR;
	int PPSS;
	int SPSS;
}SignalQuality;


typedef struct {
double TD[2];//TD's
double ASF[2];//Computed ASF values
SignalQuality Master;
SignalQuality Secondaries[2];

}LocusRecord;

typedef struct {
	MapPoint Position;
	double Velocity;  //In whatever units selected
	double TrueTMG; //Track made good in degrees -true
	double MagneticTMG; //Track made good in degrees - magnetic
	CString GPSTime;  //Actually UTC time - but supplied by GPS receiver
}DGPSRecord;


#endif
