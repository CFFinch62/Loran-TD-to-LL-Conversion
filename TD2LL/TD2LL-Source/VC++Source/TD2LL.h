// TD2LL.h : main header file for the TD2LL application
//

#if !defined(AFX_TD2LL_H__722F3AA6_DD23_11D6_842B_00105CAB078C__INCLUDED_)
#define AFX_TD2LL_H__722F3AA6_DD23_11D6_842B_00105CAB078C__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

/////////////////////////////////////////////////////////////////////////////
// CTD2LLApp:
// See TD2LL.cpp for the implementation of this class
//

class CTD2LLApp : public CWinApp
{
public:
	CTD2LLApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CTD2LLApp)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CTD2LLApp)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_TD2LL_H__722F3AA6_DD23_11D6_842B_00105CAB078C__INCLUDED_)
