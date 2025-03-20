// TD2LLDlg.cpp : implementation file
//

#include "stdafx.h"
#include <stdio.h>
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

/////////////////////////////////////////////////////////////////////////////
// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	//{{AFX_DATA(CAboutDlg)
	enum { IDD = IDD_ABOUTBOX };
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CAboutDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	//{{AFX_MSG(CAboutDlg)
	afx_msg void OnUrlStatic();
	afx_msg void OnUrlButton1();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
	//{{AFX_DATA_INIT(CAboutDlg)
	//}}AFX_DATA_INIT
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAboutDlg)
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
	//{{AFX_MSG_MAP(CAboutDlg)
	ON_BN_CLICKED(IDC_URL_STATIC, OnUrlStatic)
	ON_BN_CLICKED(IDC_URL_BUTTON1, OnUrlButton1)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CTD2LLDlg dialog

CTD2LLDlg::CTD2LLDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CTD2LLDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CTD2LLDlg)
	m_Method = -1;
	m_strSec1ASF = _T("");
	m_strSec2ASF = _T("");
	m_strMASF = _T("");
	m_Amb = FALSE;
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);

	Chains = new CLoranChain*[MAX_CHAINS];

	iChainCount=0;

	m_NavPair = "  ";
	m_NavChain = "     ";

	iSelectedChain=0;
	iSelectedSec1=1;
	iSelectedSec2=2;
	iUseCount=0;

	wgs84 = new Ellipsoid;
	sphere = new Ellipsoid;

	
	m_FileSelected = FALSE;

	m_TD1SF =0;
	m_TD2SF = 0;
	m_TD1ASF=0;
	m_TD2ASF=0;
	m_Sec1ASF=0;
	m_Sec2ASF=0;
	m_MASF=0;

	ship.SetPoint(0,0,0,sphere);

	
	
}

void CTD2LLDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CTD2LLDlg)
	DDX_Radio(pDX, IDC_NONITER_RADIO, m_Method);
	DDX_Text(pDX, IDC_SEC1ASF_EDIT, m_strSec1ASF);
	DDX_Text(pDX, IDC_SEC2ASF_EDIT, m_strSec2ASF);
	DDX_Text(pDX, IDC_MASF_EDIT, m_strMASF);
	DDX_Control(pDX, IDC_MASTER_EDIT, m_MasterEdit);
	DDX_Control(pDX, IDC_SEC1_COMBO, m_Sec1Combo);
	DDX_Control(pDX, IDC_COMBO_CHAIN, m_ChainCombo);
	DDX_Control(pDX, IDC_SEC2_COMBO, m_Sec2Combo);
	DDX_Check(pDX, IDC_OPT_CHECK, m_Amb);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CTD2LLDlg, CDialog)
	//{{AFX_MSG_MAP(CTD2LLDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_GO_BUTTON, OnGoButton)
	ON_BN_CLICKED(IDC_GOBACK_BUTTON, OnGobackButton)
	ON_BN_CLICKED(IDC_BUTTON_OPENFILE, OnButtonOpenfile)
	ON_MESSAGE(WM_UPDATEDATABLOCK, OnUpdateDataBlock)
	ON_MESSAGE(WM_ONCLEANUP, OnCleanUp)
	ON_BN_CLICKED(IDC_NONITER_RADIO, OnNoniterRadio)
	ON_BN_CLICKED(IDC_ITER_RADIO, OnIterRadio)
	ON_BN_CLICKED(IDC_LAT_STATIC, OnLatStatic)
	ON_BN_CLICKED(IDC_LON_STATIC, OnLonStatic)
	ON_BN_CLICKED(IDC_FORMAT_STATIC, OnFormatStatic)
	ON_CBN_SELCHANGE(IDC_COMBO_CHAIN, OnSelchangeComboChain)
	ON_CBN_SELCHANGE(IDC_SEC1_COMBO, OnSelchangeSec1Combo)
	ON_CBN_SELCHANGE(IDC_SEC2_COMBO, OnSelchangeSec2Combo)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CTD2LLDlg message handlers

BOOL CTD2LLDlg::OnInitDialog()
{
	CDialog::OnInitDialog();
	CButton *select;

	CString display;
	CStatic *format;

	btnFile = (CButton*)GetDlgItem(IDC_BUTTON_OPENFILE);
	select = (CButton*)GetDlgItem(IDC_NONITER_RADIO);
//	int loaded;

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon
	
	// TODO: Add extra initialization here

	//m_Method =ITER;
	m_Amb=FALSE;
	UpdateData(TRUE);

#ifdef RESTRICTED
	m_Method =ITER;
	UpdateData(FALSE);
	btnFile->EnableWindow(FALSE);
	select->EnableWindow(FALSE);

#endif

#ifndef RESTRICTED
	m_Method =NONITER;
	UpdateData(FALSE);
	btnFile->EnableWindow(TRUE);

#endif

	if(LoadLoranChainInfo())  //load data from a text file
		{
		m_ChainCombo.SetCurSel(0);	
		InitialiseNavComboBoxes();  //Set combo box entries
		
		StoreTXInfo();

		if(m_Method == NONITER)
			{

			ComputeSphereOriginOffset(); //compute the offset of an osculating sphere
			ConvertToSphere(&m_MPMaster);  //do datum transformation
			ConvertToSphere(&m_MPSecondary1);
			ConvertToSphere(&m_MPSecondary2);
			}
		}
	else
		{
		OnOK();
		}



	m_dispUnits[0] = DECD;
	m_dispUnits[1] = DECD;

	format = (CStatic*)GetDlgItem(IDC_FORMAT_STATIC);

	format->SetWindowText("Decimal Degrees");


	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CTD2LLDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CTD2LLDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CTD2LLDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}


void CTD2LLDlg::InitialiseNavComboBoxes()
{

	int iTXCount;
	int i=0;
	
	CString tmpName;
	CString strMaster;
	CString strCombo;
//	CLoranTransmitter *tmpTX;

	
		iTXCount = Chains[0]->GetTXCount();//get the first chains number of transmitters

		for(i=0;i<iChainCount;++i)
			{
			strCombo = Chains[i]->GetGRI()+" "+Chains[i]->GetName();
			//strCombo+=" (";
			//tmpTX = Chains[i].GetTransmitter(0);  //tranmitter 0 is the master station
			//strMaster=tmpTX->GetName();
			//strCombo+=strMaster;
			//strCombo+=")";
			m_ChainCombo.AddString(strCombo);
			}

		m_ChainCombo.SetCurSel(iSelectedChain);

		UpdateSecondaryCombos();

}


void CTD2LLDlg::OnSelchangeComboChain() 
{
	// TODO: Add your control notification handler code here

	iSelectedSec1=1;
	iSelectedSec2=2;
	UpdateSecondaryCombos();
/*	StoreTXInfo();  //get and store the transmitter information from transmitter structures
	ComputeSphereOriginOffset(); //recompute
	ConvertToSphere(&m_MPMaster);  //do datum transformation
    ConvertToSphere(&m_MPSecondary1);
	ConvertToSphere(&m_MPSecondary2);*/
}

void CTD2LLDlg::OnSelchangeSec1Combo() 
{
	// TODO: Add your control notification handler code here
	if(m_Sec1Combo.GetCurSel()==m_Sec2Combo.GetCurSel())
		{
			AfxMessageBox("Cannot have two secondaries the same", MB_OK);
			m_Sec1Combo.SetCurSel(iSelectedSec1-1);

		}
	else
	{
		iSelectedSec1 = m_Sec1Combo.GetCurSel()+1;
	}

/*	StoreTXInfo();  //get and store the transmitter information from transmitter structures
	ComputeSphereOriginOffset(); //recompute
    ConvertToSphere(&m_MPSecondary1); */
	
}

void CTD2LLDlg::OnSelchangeSec2Combo() 
{
	// TODO: Add your control notification handler code here
	if(m_Sec1Combo.GetCurSel()==m_Sec2Combo.GetCurSel())
		{
			AfxMessageBox("Cannot have two secondaries the same", MB_OK);
			m_Sec2Combo.SetCurSel(iSelectedSec2-1);

		}
	else
	{

	iSelectedSec2 = m_Sec2Combo.GetCurSel()+1;
	}

	/*StoreTXInfo();  //get and store the transmitter information from transmitter structures
	ComputeSphereOriginOffset(); //recompute
    ConvertToSphere(&m_MPSecondary2);*/
}





void CTD2LLDlg::GetLRSNavSettings(CString *GRI, CString *Pair)
{
*GRI = m_NavChain;
*Pair = m_NavPair;

}

void CTD2LLDlg::SetLRSNavSettings(CString initChain, CString initPair)
{

int i;
int j;

CString tmp;


if(!(initChain.IsEmpty()) || !(initPair.IsEmpty()))
{
	m_NavChain = initChain;
	m_NavPair = initPair;

	for(i=0;i<iChainCount;++i)
	{
	tmp = Chains[i]->GetGRI();

		if(!m_NavChain.Compare(tmp))
		{
			iSelectedChain = i;

			for(j=0;j<Chains[iSelectedChain]->GetTXCount()-1;++j)
			{
				tmp = Chains[iSelectedChain]->GetTransmitter(j+1)->GetDesignator();
				
				if(m_NavPair.GetAt(0)==tmp)
				{
					iSelectedSec1 = j;
				}

				if(m_NavPair.GetAt(1)==tmp)
				{
					iSelectedSec2 = j;
				}
			}

		}
	}

}


}

void CTD2LLDlg::UpdateSecondaryCombos()
{

int iChainSelected;

int numTX;
CString strCombo;

iSelectedChain = m_ChainCombo.GetCurSel();
iChainSelected = iSelectedChain;

m_MasterEdit.SetWindowText(Chains[iChainSelected]->GetTransmitter(0)->GetName());
numTX=Chains[iChainSelected]->GetTXCount();

m_Sec1Combo.ResetContent();
m_Sec2Combo.ResetContent();

for(int i=1;i<numTX;++i)
	{
	m_Sec1Combo.AddString(Chains[iChainSelected]->GetTransmitter(i)->GetName()+" ("+Chains[iChainSelected]->GetTransmitter(i)->GetDesignator()+")");
	m_Sec2Combo.AddString(Chains[iChainSelected]->GetTransmitter(i)->GetName()+" ("+Chains[iChainSelected]->GetTransmitter(i)->GetDesignator()+")");
	}

m_Sec1Combo.SetCurSel(iSelectedSec1-1);
m_Sec2Combo.SetCurSel(iSelectedSec2-1);

}


void CTD2LLDlg::SetChains(CLoranChain **initChains, int numChains)
{

	iChainCount = numChains;
	Chains = initChains;

}


int CTD2LLDlg::LoadLoranChainInfo()
{


//void LoadChaininfo(chaininfo *group, char *gri)


FILE *tx_info;

char designator;
char line[200];
int i;
int j=0;
double ED;
int tx_count=0;
int chain_limit=9999;//enough for plenty of chains!
CString GRI;
CString ChainName;
double lat,lon;
double pow, nom_ecd;

CString name;
MapPoint posTemp;

#ifdef RESTRICTED
chain_limit=3;
#endif

if((tx_info = fopen("loraninfo.dat","r"))==NULL)
	{
	i = AfxMessageBox("Cannot find Transmitter Information");

	return(0);	
	}


for(i = 0;i<10;++i)
	{
   fgets(line,200,tx_info);
   }



while(fgets(line,200,tx_info) && j<chain_limit)  //and limit to three chains
	{
   if(line[0]=='e')
   	{
      break;
      }

   if(isdigit(line[0]))
   	{
	 
	   GRI = strtok(line," ");
	   ChainName = strtok(NULL,"\n");
     Chains[iChainCount]=new CLoranChain(GRI);
	   Chains[iChainCount]->SetName(ChainName);

	   
       fgets(line,200,tx_info);

		if(line[0]=='M')
      	 {
	
  		 ED=0;  //this is a master station
         strtok(line," ");
         strtok(NULL," ");
       
	     name = strtok(NULL," ");
  		 pow = atof(strtok(NULL," "));  //power in kilowatts
		 nom_ecd = atof(strtok(NULL," "));  // in microseconds
		 lat = atof(strtok(NULL," "));
		 lon = atof(strtok(NULL,"\n"));

         posTemp.SetPoint(lat,lon ,0,wgs84);
		 Chains[iChainCount]->SetTransmitter(name,posTemp, ED,'M');
		 tx_count++;	

         }

      fgets(line,200,tx_info);
		 

		while(line[0]!='*')
      	{
         designator = line[0];
		 strtok(line," ");
		 ED = atof(strtok(NULL," "));
		 
         name=strtok(NULL," ");
		 pow = atof(strtok(NULL," "));  //power in kilowatts
		 nom_ecd = atof(strtok(NULL," "));  // in microseconds
		 lat = atof(strtok(NULL," "));
		 lon =  atof(strtok(NULL,"\n"));

         posTemp.SetPoint(lat, lon,0,wgs84);
		 Chains[iChainCount]->SetTransmitter(name,posTemp, ED,designator);
		 tx_count++;	
         fgets(line,200,tx_info);

		 
         }
		j++; //increment when chain found

		iChainCount++;
      }



   }

fclose(tx_info);

return(1); //data file found

}

void CTD2LLDlg::OnGoButton() 
{
	// TODO: Add your control notification handler code here
	CEdit *td1;
	CEdit *td2;
	CEdit *lat;
	CEdit *lon;

	CEdit *message;
	CString strTD1;
	CString strTD2;
	CString strLat;
	CString strLon;

	MapPoint tmp;


	tdfile = (FILE*)fopen("tds.dat","w");
	UpdateData(TRUE);

	if(m_FileSelected==TRUE)
		{
		if(m_Method==NONITER)
			{
			strOutfilename = strPreExtension+".lln";
			}
		else
			{
			strOutfilename = strPreExtension+".lli";

			lat = (CEdit*)GetDlgItem(IDC_LATITUDE_EDIT);
			lat->GetWindowText(strLat); 
			lon = (CEdit*)GetDlgItem(IDC_LONGITUDE_EDIT);
			lon->GetWindowText(strLon); 

			if(strLat.IsEmpty() || strLon.IsEmpty())
				{
				AfxMessageBox("Enter position estimate and re-open the file!");
				m_FileSelected = FALSE;
				return;

				}

			}

		ptrInputFile = fopen(strFilename.GetBuffer(30),"r");//OpenFileRead(strFilename);
		strFilename.ReleaseBuffer();
		ptrOutputFile = OpenFileWrite(strOutfilename);
		}


	iUseCount++;

#ifdef RESTRICTED
	if(iUseCount==10)
		{
		Register();
		}
#endif


	if(m_FileSelected==FALSE)   //then read from edit boxes
		{
		td1 = (CEdit*)GetDlgItem(IDC_TD1_EDIT);
		td2 = (CEdit*)GetDlgItem(IDC_TD2_EDIT);
		lat = (CEdit*)GetDlgItem(IDC_LATITUDE_EDIT);
		lon = (CEdit*)GetDlgItem(IDC_LONGITUDE_EDIT);

		td1->GetWindowText(strTD1); //get TD and Lat/Lon values from Dialog Boxes
		td2->GetWindowText(strTD2);
		lat->GetWindowText(strLat); 
		lon->GetWindowText(strLon); 

		
		if(strTD1.IsEmpty() || strTD2.IsEmpty())
			{
			AfxMessageBox("Please enter TDs!");
			return;
			}

			m_dblTD1 = str2dbl(strTD1);  //convert the TD values to doubles
			m_dblTD2 = str2dbl(strTD2);  

			if(m_Method==NONITER)
				{
				DoTD2LLConversion();
				}
			else
				{	
				if(strLat.IsEmpty() || strLon.IsEmpty())
					{
					AfxMessageBox("Enter position estimate!");
					return;
					}

				DoTD2LLConversion2();
				}
		}

	else						//read from file
		{
		message = (CEdit*)GetDlgItem(IDC_MESSAGE_EDIT);
		message->SetWindowText("Processing...");
		hThread = AfxBeginThread(ReadFileThread,this); //Pass handle to this dialog which is derived from CWnd
		}

}

CTD2LLDlg::~CTD2LLDlg()
{

	int i;

	for(i=0;i<iChainCount;++i)
		delete Chains[i];

	delete [MAX_CHAINS] Chains;
	delete wgs84;  //delete ellipsoid
	delete sphere; 

}

void CTD2LLDlg::OnGobackButton() 
{
	// TODO: Add your control notification handler code here
	CEdit *lat;
	CEdit *lon;
	CEdit *td1;
	CEdit *td2;

	CString strlat;
	CString strlon;
	MapPoint position;
//	double mdistance, sec1distance,sec2distance;
	double dbltd1, dbltd2;
//	double *s1, *s2, *m, *p;
//	double ThetaPSec1;
//	double ThetaPSec2;
//	double ThetaPM;
//	double radius;
	double temp1,temp2,temp3;
	double lat1, lon1;



//	s1 = new double[3];
//	s2 = new double[3];
//	m = new double[3];
//	p = new double[3];

	//m_MPSecondary1.ToECEF();
	//m_MPSecondary2.ToECEF();
	//m_MPMaster.ToECEF();

		

	UpdateData(TRUE);
	iUseCount++;

#ifdef RESTRICTED
	if(iUseCount==10)
		{
		Register();
		}
#endif


	StoreTXInfo();  //get and store the transmitter information from transmitter structures
	
	lat = (CEdit*)GetDlgItem(IDC_LATITUDE_EDIT);
	lon = (CEdit*)GetDlgItem(IDC_LONGITUDE_EDIT);

	td1 = (CEdit*)GetDlgItem(IDC_TD1_EDIT);
	td2 = (CEdit*)GetDlgItem(IDC_TD2_EDIT);


	lat->GetWindowText(strlat);
	lon->GetWindowText(strlon);


	switch(sscanf(strlat,"%lf %lf %lf",&temp1,&temp2,&temp3))
	{
	case 0: 
		lat1=0; 
	break;
	
	case 1: 
		lat1=fabs(temp1); 
	break;

	case 2: 
		lat1=fabs(temp1)+temp2/60; 
	break;
	
	case 3: 
		lat1=fabs(temp1)+temp2/60+temp3/3600; 
	break;

	}

	
	lat1 = (double)sign(temp1)*lat1;

	switch(sscanf(strlon,"%lf %lf %lf",&temp1,&temp2,&temp3))
	{
	case 0: 
		lon1=0; 
	break;
	
	case 1: 
		lon1=fabs(temp1); 
	break;
	
	case 2: 
		lon1=fabs(temp1)+temp2/60; 
	break;

	case 3: 
		lon1=fabs(temp1)+temp2/60+temp3/3600; 
	break;
	}

	
	lon1 = (double)sign(temp1)*lon1;

   UpdateData(TRUE);
	
	LL2TD( lat1, lon1, wgs84, dbltd1, dbltd2);

//   delete [] s1;
//   delete [] s2;
//   delete [] m;
//   delete [] p;

	td1->SetWindowText(dbl2str(dbltd1)); //get TD values from Dialog Box
	td2->SetWindowText(dbl2str(dbltd2));
	
	
}


void CTD2LLDlg::DoTD2LLConversion()
{
//double opt1;
//double opt2;
//double angle1;
//double angle2;
//double radius;
static int stored=0;

//matrix A;
//vector b;
//vector answer;
//int i;

UpdateData(TRUE);

	TD2LL( m_dblTD1, m_dblTD2, ship);


	if(m_FileSelected==FALSE)
		{

		DisplayResult();
		
		
		}
	else
		{

		strLatitude.Format("%lf",ship.GetLatitude());
		strLongitude.Format("%lf",ship.GetLongitude());
		ptrOutputFile->Write(strLatitude +" " + strLongitude, strLatitude.GetLength()+strLongitude.GetLength()+1);
		ptrOutputFile->Write("\n",1);

		//output to a file
		}

	
}

void CTD2LLDlg::DoTD2LLConversion2()  //iterative version
{
	CEdit *editLat;
	CEdit *editLon;
	CString strLat;
	CString strLon;

	editLat = (CEdit*)GetDlgItem(IDC_LATITUDE_EDIT);
	editLon = (CEdit*)GetDlgItem(IDC_LONGITUDE_EDIT);

	editLat->GetWindowText(strLat);
	editLon->GetWindowText(strLon);

	MapPoint estimate;

    estimate.SetPoint(str2dbl(strLat),str2dbl(strLon),0,wgs84);
   

	TD2LL2( m_dblTD1, m_dblTD2, estimate);

#if 0 // Moved to TD2LL2()
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
#endif

	if(m_FileSelected==0)
		{
		ship = estimate;
		DisplayResult();
		}
	else
		{
		//output to a text file

		strLat.Format("%lf",estimate.GetLatitude());
		strLon.Format("%lf",estimate.GetLongitude());
		ptrOutputFile->Write(strLat +" " + strLon, strLat.GetLength()+strLon.GetLength()+1);
		ptrOutputFile->Write("\n",1);


		}

}


void CTD2LLDlg::OnButtonOpenfile() 
{
	// TODO: Add your control notification handler code here

CString strMode;

//	CButton* proc;

	OPENFILENAME ofn;
	static char buffer[MAX_PATH];
	char curdir[MAX_PATH];

	_chdir(DATA_DIR);
	//_chdir(TEMP_DIR);
	GetCurrentDirectory(MAX_PATH,curdir);

	memset(&ofn, 0, sizeof(ofn));
	ofn.hwndOwner=this->m_hWnd;
	ofn.lStructSize = sizeof(ofn);
	ofn.lpstrFilter = "LRS Loran-C Data File (*.loc)\0*.loc\0";
	ofn.nMaxFile=MAX_PATH;
	ofn.lpstrFile=(LPSTR)buffer;
	ofn.lpstrInitialDir=curdir;
	ofn.Flags=OFN_HIDEREADONLY|OFN_FILEMUSTEXIST|OFN_PATHMUSTEXIST;

	int nResult = ::GetOpenFileName(&ofn);

	if(!nResult)
		return;

	strFilename=ofn.lpstrFile;

	if(strFilename.IsEmpty()==FALSE)
		{

		m_FileSelected = TRUE;
		}


	strExtension=strFilename.Mid(ofn.nFileExtension-1,strFilename.GetLength()-ofn.nFileExtension+1);
	strPreExtension=strFilename.Mid(0,ofn.nFileExtension-1);

/*
	if(m_Method==NONITER)
		strOutfilename = strPreExtension+".lln";
	else
		strOutfilename = strPreExtension+".lli";

	if(m_FileSelected==TRUE)
		{
		ptrInputFile = fopen(strFilename.GetBuffer(30),"r");//OpenFileRead(strFilename);
		strFilename.ReleaseBuffer();
		ptrOutputFile = OpenFileWrite(strOutfilename);
		}
*/

}
	

void CTD2LLDlg::OnUpdateDataBlock(WPARAM wParam, LPARAM lParam)
{

	//AfxMessageBox("OK");


	GetLRSPosition();


}


void CTD2LLDlg::OnCleanUp(WPARAM wParam, LPARAM lParam)
{
CEdit *message;

		message = (CEdit*)GetDlgItem(IDC_MESSAGE_EDIT);

		//AfxMessageBox("iRead is 0");

		fclose(ptrInputFile);
		ptrOutputFile->Close();

		m_FileSelected=FALSE;
		//btnFile->EnableWindow(FALSE);
		fclose(tdfile);
		message->SetWindowText("Done...");

//		delete(ptrInputFile);
		delete(ptrOutputFile);

}

UINT CTD2LLDlg::ReadFileThread(LPVOID pParam)
{


CString ExceptionMessage;
CTD2LLDlg *dlg;

char input;
//int iRead;
int sentCount=0;

HWND CallingWindowHandle;

dlg=(CTD2LLDlg *)pParam;
	
CallingWindowHandle = dlg->m_hWnd;


fseek(dlg->ptrInputFile,0,SEEK_SET);//->SeekToBegin();


if(dlg->ptrInputFile!=NULL)
	{

	
	for(;;)
		{

		dlg->TextMessage="";

		do
			{	
			//try
				//{
			
				//iRead = dlg->ptrInputFile->Read(&input,1);
				//}

			/*catch (CFileException *e)
				{
				if(e->m_cause ==CFileException::endOfFile)
					{
					AfxMessageBox("End of File reached");
					::SendMessage(CallingWindowHandle,WM_ONCLEANUP ,0,0);

					AfxEndThread(0);
					}
				}*/


			if(!feof(dlg->ptrInputFile))
						{

						fscanf(dlg->ptrInputFile,"%c",&input);

						}
			else
				
						{

						
						::SendMessage(CallingWindowHandle,WM_ONCLEANUP ,0,0);

						AfxEndThread(0);
					
						}

			
				dlg->TextMessage+=input;
			

			} while(dlg->TextMessage.Find("end data")<=-1 || feof(dlg->ptrInputFile));

			//AfxMessageBox("Found");
	
		if(dlg->TextMessage.GetLength()!=0)
			{
			::SendMessage(CallingWindowHandle,WM_UPDATEDATABLOCK ,0,0);
			}

		}

	}

else
	{
	AfxMessageBox("Post-processing not started");
	::SendMessage(CallingWindowHandle,WM_ONCLEANUP ,0,0);
	
	
	}


return(0);

}
	


int CTD2LLDlg::GetLRSPosition()
{

   int result;
//   long *seconds;
//   int ret_val;

   CString gri;
   CString pair;

   result=GetTDRecord(); //Convert this to read from TextMessage global
 
   if(result == RECORD_FOUND)
     	{
	   m_dblTD1 = record.TD[0];
	   m_dblTD2 = record.TD[1];

   		if(m_Method==NONITER)
			{
			DoTD2LLConversion();
			}
		else
			{	
			DoTD2LLConversion2();
			}

	   
//	      ret_val = TD2LL( Position);

        }

      if(result == NO_RECORD)
      	{
		//No record found this time
         }

return result;
}

int CTD2LLDlg::GetTDRecord()
{

CString strStatusLine;
CString strTXLine;
CString strChainandMTX = "      ";
CString strChainandSec1TX = "      ";
CString strChainandSec2TX = "      ";
CString strTDM;  //Master TD line - not used for anything else
CString strTDSec1;  //First secondary TD line
CString strTDSec2;
CString temp;

int master_found=0;
int sec1_found=0;
int sec2_found=0;
int line_index;
int td_found=0;
int tmp_length=63;
int line_length;


strChainandMTX = m_NavChain;
strChainandMTX +="M";

strChainandSec1TX = m_NavChain;
strChainandSec1TX +=m_NavPair.GetAt(0);

strChainandSec2TX = m_NavChain;
strChainandSec2TX +=m_NavPair.GetAt(1);


   if(TextMessage.Find("Status:")>-1)
   	{
	
    if((line_index=TextMessage.Find(strChainandMTX))>-1)
		{
		
		strTXLine = TextMessage.Mid(line_index,tmp_length+1);
		line_length=strTXLine.Find('\n');
		strTXLine = TextMessage.Mid(line_index,tmp_length);

		if(line_length==tmp_length)
			{
			master_found=1;

			strTDM = strTXLine.Right(8);

			temp = strTXLine.Mid(12,13);  //SPSS - Sample Point Signal Strength
			record.Master.SPSS = atoi(temp.GetBuffer(40));
			temp.ReleaseBuffer();


			temp = strTXLine.Mid(16,17);  //PPSS - Peak Point Signal Strength
			record.Master.PPSS = atoi(temp.GetBuffer(40));
			temp.ReleaseBuffer();

			temp = strTXLine.Mid(22,23);  //SNR - Signal - Noise Ration 
			record.Master.SNR = atoi(temp.GetBuffer(40));
			temp.ReleaseBuffer();
			}


		}

    if(((line_index=TextMessage.Find(strChainandSec1TX))>-1) && master_found)
		{
		


		strTXLine = TextMessage.Mid(line_index,tmp_length+1);
		
		line_length=strTXLine.Find('\n');
		strTXLine = TextMessage.Mid(line_index,tmp_length);
		
		if(line_length==tmp_length)
			{
			sec1_found=1;
			strTDSec1 = strTXLine.Right(8);
			record.TD[0] = atof(strTDSec1.GetBuffer(40))/1000.0;



			strTDSec1.ReleaseBuffer();

			temp = strTXLine.Mid(12,13);  //SPSS - Sample Point Signal Strength
			record.Secondaries[0].SPSS = atoi(temp.GetBuffer(40));
			temp.ReleaseBuffer();


			temp = strTXLine.Mid(16,17);  //PPSS - Peak Point Signal Strength
			record.Secondaries[0].PPSS = atoi(temp.GetBuffer(40));
			temp.ReleaseBuffer();

			temp = strTXLine.Mid(21,23);  //SNR - Signal - Noise Ration 
			record.Secondaries[0].SNR = atoi(temp.GetBuffer(40));
			temp.ReleaseBuffer();
			}


		}

    if( ((line_index=TextMessage.Find(strChainandSec2TX))>-1) && master_found)
		{
		

		strTXLine = TextMessage.Mid(line_index,tmp_length+1);
		line_length=strTXLine.Find('\n');
		strTXLine = TextMessage.Mid(line_index,tmp_length);

		if(line_length==tmp_length)
			{
			sec2_found=1;
			strTDSec2 = strTXLine.Right(8);

			record.TD[1] = atof(strTDSec2.GetBuffer(40))/1000.0;
			strTDSec2.ReleaseBuffer();

			temp = strTXLine.Mid(12,13);  //SPSS - Sample Point Signal Strength
			record.Secondaries[1].SPSS = atoi(temp.GetBuffer(40));
			temp.ReleaseBuffer();


			temp = strTXLine.Mid(16,17);  //PPSS - Peak Point Signal Strength
			record.Secondaries[1].PPSS = atoi(temp.GetBuffer(40));
			temp.ReleaseBuffer();

			temp = strTXLine.Mid(21,23);  //SNR - Signal - Noise Ration 
			record.Secondaries[1].SNR = atoi(temp.GetBuffer(40));
			temp.ReleaseBuffer();
			}

		}

	   //*time = strtol(sec_string,&eptr,10);

	
		
        if(master_found && sec1_found && sec2_found)
		{
			td_found=1;
		}

	fprintf(tdfile,"%lf %lf\n",record.TD[0], record.TD[1]);

}

   

return(td_found);

}


void CTD2LLDlg::OnNoniterRadio() 
{
	// TODO: Add your control notification handler code here


/*
	CButton* btnFile;

#ifndef RESTRICTED

	btnFile = (CButton*)GetDlgItem(IDC_BUTTON_OPENFILE);
	UpdateData(TRUE);
	btnFile->EnableWindow(TRUE);
#endif */


	
}

void CTD2LLDlg::OnIterRadio() 
{
	// TODO: Add your control notification handler code here
/*
	CButton* btnFile;

#ifndef RESTRICTED 
	btnFile = (CButton*)GetDlgItem(IDC_BUTTON_OPENFILE);
	UpdateData(TRUE);
	btnFile->EnableWindow(TRUE);
#endif
*/	


}

void CTD2LLDlg::OnOK() 
{
	// TODO: Add extra validation here

	CDialog::OnCancel();
	
}

void CTD2LLDlg::Register()
{

RegisterPopup *popup = new RegisterPopup(this);

popup->DoModal();
iUseCount=0; //reset use counter


}

void CAboutDlg::OnUrlStatic() 
{
	// TODO: Add your control notification handler code here

	ShellExecute(this->m_hWnd, "open", "http://www.informatics.bangor.ac.uk/Loran-C",NULL, NULL, SW_SHOW);
	
}

void CAboutDlg::OnUrlButton1() 
{
	// TODO: Add your control notification handler code here
		ShellExecute(this->m_hWnd, "open", "http://www.informatics.bangor.ac.uk/Loran-C",NULL, NULL, SW_SHOW);
}



void CTD2LLDlg::OnLatStatic() 
{
	// TODO: Add your control notification handler code here



}


void CTD2LLDlg::OnLonStatic() 
{
	// TODO: Add your control notification handler code here


	
}


void CTD2LLDlg::DisplayResult()
{

CEdit *editLat;
CEdit *editLon;
CStatic *format;


double degrees, minutes,seconds;

editLat = (CEdit*)GetDlgItem(IDC_LATITUDE_EDIT);
editLon = (CEdit*)GetDlgItem(IDC_LONGITUDE_EDIT);
format = (CStatic*)GetDlgItem(IDC_FORMAT_STATIC);


	switch(m_dispUnits[0]%3)
		{
		case DECD:

			strLatitude.Format("%lf",ship.GetLatitude());
			strLongitude.Format("%lf",ship.GetLongitude());
			format->SetWindowText("Decimal Degrees");

		break;

		case DDECM:


			degrees = (int)ship.GetLatitude();
			minutes = (ship.GetLatitude()-degrees)*60;

			strLatitude.Format("%.0lf  %.4lf",degrees,fabs(minutes));

			degrees = (int)ship.GetLongitude();
			minutes = (ship.GetLongitude()-degrees)*60;

			strLongitude.Format("%.0lf  %.4lf",degrees,fabs(minutes));
			format->SetWindowText("Degrees DecimalMinutes");


		break;

		case DMS:

			degrees = (int)ship.GetLatitude();
			minutes = (int)((ship.GetLatitude()-degrees)*60.0);

			seconds = ((ship.GetLatitude()-degrees)*60 - minutes)*60.0;

			strLatitude.Format("%.0lf  %.0lf  %.3lf",degrees,fabs(minutes),fabs(seconds));

			degrees = (int)ship.GetLongitude();
			minutes = (int)((ship.GetLongitude()-degrees)*60.0);

			seconds = ((ship.GetLongitude()-degrees)*60 - minutes)*60.0;

			strLongitude.Format("%.0lf  %.0lf  %.3lf",degrees,fabs(minutes),fabs(seconds));

			format->SetWindowText("Degrees Minutes Seconds");


		break;

		}


		
	
		editLat->SetWindowText(strLatitude);
		editLon->SetWindowText(strLongitude);

}


void CTD2LLDlg::OnFormatStatic() 
{
	// TODO: Add your control notification handler code here

	CStatic *unit;



	unit = (CStatic*)GetDlgItem(IDC_LON_STATIC);
	m_dispUnits[0]++;
	m_dispUnits[1]++;
	DisplayResult();


	
}

