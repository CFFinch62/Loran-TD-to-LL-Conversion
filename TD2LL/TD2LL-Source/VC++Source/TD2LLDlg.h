// TD2LLDlg.h : header file
//

#include "LoranChain.h"
#include "Elipsoid.h"
#include "MapPoint.h"
#include "ECEF.h"	// Added by ClassView

#if !defined(AFX_TD2LLDLG_H__722F3AA8_DD23_11D6_842B_00105CAB078C__INCLUDED_)
#define AFX_TD2LLDLG_H__722F3AA8_DD23_11D6_842B_00105CAB078C__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CTD2LLDlg dialog

//user defined messages

#define WM_UPDATEDATABLOCK (WM_USER+100)
#define WM_ONCLEANUP (WM_USER+101)

#define NO_RECORD 0
#define RECORD_FOUND 1
#define NOSF 0
#define WITHSF 1
//#define HEIGHT

//#define RESTRICTED

#define DATA_DIR ".\\"

#define TEMP_DIR "m:\\programs\\"

#define DECD 0
#define DDECM 1 
#define DMS 2

/*const static double SeaCoeffs[4] = {
1.248395207657581e-6, 0.0006660598910310626,  2.502361205425209e-7, 3.953855068621391e-10
};*/


const static double SeaCoeffsUpper[3] = {
129.04398, -0.40758, 0.00064576438
};

const static double SeaCoeffsLower[3] = {
2.7412979, -0.011402, 0.00032774624
};


class CTD2LLDlg : public CDialog
{
// Construction
public:
	void DisplayResult();
	void Register();
	CString TextMessage;
	void DoTD2LLConversion2();

	void LL2TD( double lat1, double lon1, Ellipsoid *wgs84, double &dbltd1, double &dbltd2);
	void TD2LL( double td1, double td2, MapPoint &ship);
	void TD2LL2( double td1, double td2, MapPoint &estimate);   // Iterative version
	
	void AdjustForSF(void);
	void CalculateCosBetaX(double *opt1, double *opt2);
	void CalculateAArray();
	void CalculateUArray();
	void ComputeThetas(void);
	void DoTD2LLConversion(void);
	void CalculateP(void);
	void StoreTXInfo();
	void ConvertToEllipsoid(MapPoint *initPoint);
	MapPoint m_MPTangentPoint;
	void ComputeSphereOriginOffset();
	void ConvertToSphere(MapPoint *initPoint);
	double GetSeaWaterDelay(double initDistance);
	CTD2LLDlg(CWnd* pParent = NULL);	// standard constructor
	~CTD2LLDlg();
	void InitialiseNavComboBoxes();
	void SetLRSNavSettings(CString initChain, CString initPair);
	void GetLRSNavSettings(CString *GRI, CString *Pair);
	void UpdateSecondaryCombos();
	void SetChains(CLoranChain **initChains, int numChains);
	void OnSelchangeComboChain(void) ;
	void OnSelchangeSec1Combo(void); 
	void OnSelchangeSec2Combo(void); 	
	int LoadLoranChainInfo(void);
	int GetLRSPosition(void);
	int GetTDRecord(void);
	static UINT ReadFileThread(LPVOID pParam);

	FILE *ptrInputFile;
	CFile *ptrOutputFile;
	FILE *tdfile;

// Dialog Data
	//{{AFX_DATA(LoranCSetup)

	CEdit	m_MasterEdit;
	CComboBox	m_Sec2Combo;
	CComboBox	m_Sec1Combo;
	CComboBox	m_ChainCombo;
	
	//}}AFX_DATA
// Dialog Data
	//{{AFX_DATA(CTD2LLDlg)
	enum { IDD = IDD_TD2LL_DIALOG };
	int		m_Method;
	CString	m_strSec1ASF;
	CString	m_strSec2ASF;
	CString	m_strMASF;
	BOOL	m_Amb;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CTD2LLDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	//{{AFX_MSG(CTD2LLDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnGoButton();
	afx_msg void OnGobackButton();
	afx_msg void OnButtonOpenfile();
	afx_msg void OnUpdateDataBlock(WPARAM wParam, LPARAM lParam);
	afx_msg void OnCleanUp(WPARAM wParam, LPARAM lParam);
	afx_msg void OnNoniterRadio();
	afx_msg void OnIterRadio();
	virtual void OnOK();
	afx_msg void OnLatStatic();
	afx_msg void OnLonStatic();
	afx_msg void OnFormatStatic();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

private:
	int m_dispUnits[2];
	int m_dispMode;
	CString strLongitude;
	CString strLatitude;
	CButton* btnFile;
	MapPoint m_MPEstimate;
	int m_FileSelected;
	CString strPreExtension;
	CString strExtension;
	CString strFilename;
	CString strOutfilename;
	double m_ThetaSec1Sec2;
	double m_CosBetaX;
	double m_CosBetaX2;
	double m_UArray[3];
	double m_AArray[2];
	double m_P[2];
	MapPoint m_MPSecondary2;
	MapPoint m_MPSecondary1;
	MapPoint m_MPMaster;
	double m_ED2;
	double m_ED1;
	ECEF m_ecefSphereOffset;
	double m_dblTD2;
	double m_dblTD1;
	int iSelectedSec2;
	int iSelectedSec1;
	int iSelectedChain;
	int iUseCount;
	CString m_NavPair;
	CString m_NavChain;
	double m_Sec1ASF;
	double m_Sec2ASF;
	double m_MASF;
	double m_TD1ASF;
	double m_TD2ASF;
	double m_TD1SF;
	double m_TD2SF;

	int iChainCount;

	CLoranChain **Chains;

	BOOL bNavSettingsRead;  //Chain and tx info have been read from file if TRUE
	Ellipsoid *wgs84;
	Ellipsoid *sphere;

	double m_ThetaMSec1;
	double m_ThetaMSec2;
	double m_ThetaMRX;
	double m_ThetaSec1RX;
	double m_ThetaSec2RX;
	double m_K;

	CWinThread *hThread;

	LocusRecord record;
	MapPoint ship;



};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_TD2LLDLG_H__722F3AA8_DD23_11D6_842B_00105CAB078C__INCLUDED_)
