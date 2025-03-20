#if !defined(AFX_AVAILABLE_H__DB55C4C0_FAEE_11D6_842B_00105CAB078C__INCLUDED_)
#define AFX_AVAILABLE_H__DB55C4C0_FAEE_11D6_842B_00105CAB078C__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// Available.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// Available dialog

class Available : public CDialog
{
// Construction
public:
	Available(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(Available)
	enum { IDD = IDD_AVAILABLE_DIALOG };
		// NOTE: the ClassWizard will add data members here
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(Available)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(Available)
		// NOTE: the ClassWizard will add member functions here
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_AVAILABLE_H__DB55C4C0_FAEE_11D6_842B_00105CAB078C__INCLUDED_)
