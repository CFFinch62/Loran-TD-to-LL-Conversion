// Available.cpp : implementation file
//

#include "stdafx.h"
#include "TD2LL.h"
#include "Available.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// Available dialog


Available::Available(CWnd* pParent /*=NULL*/)
	: CDialog(Available::IDD, pParent)
{
	//{{AFX_DATA_INIT(Available)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}


void Available::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(Available)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(Available, CDialog)
	//{{AFX_MSG_MAP(Available)
		// NOTE: the ClassWizard will add message map macros here
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// Available message handlers
