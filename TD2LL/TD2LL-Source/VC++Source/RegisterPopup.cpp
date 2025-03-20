// RegisterPopup.cpp : implementation file
//

#include "stdafx.h"
#include "TD2LL.h"
#include "RegisterPopup.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// RegisterPopup dialog


RegisterPopup::RegisterPopup(CWnd* pParent /*=NULL*/)
	: CDialog(RegisterPopup::IDD, pParent)
{
	//{{AFX_DATA_INIT(RegisterPopup)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}


void RegisterPopup::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(RegisterPopup)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(RegisterPopup, CDialog)
	//{{AFX_MSG_MAP(RegisterPopup)
	ON_BN_CLICKED(IDC_URL_BUTTON2, OnUrlButton2)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// RegisterPopup message handlers

void RegisterPopup::OnUrlButton2() 
{
	// TODO: Add your control notification handler code here

	ShellExecute(this->m_hWnd, "open", "http://www.informatics.bangor.ac.uk/Loran-C",NULL, NULL, SW_SHOW);
	
}
