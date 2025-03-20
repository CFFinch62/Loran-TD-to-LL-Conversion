#if !defined(AFX_REGISTERPOPUP_H__80CABB80_F7CB_11D6_842B_00105CAB078C__INCLUDED_)
#define AFX_REGISTERPOPUP_H__80CABB80_F7CB_11D6_842B_00105CAB078C__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// RegisterPopup.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// RegisterPopup dialog

class RegisterPopup : public CDialog
{
// Construction
public:
	RegisterPopup(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(RegisterPopup)
	enum { IDD = IDD_REGISTERPOPUP_DIALOG };
		// NOTE: the ClassWizard will add data members here
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(RegisterPopup)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(RegisterPopup)
	afx_msg void OnUrlButton2();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_REGISTERPOPUP_H__80CABB80_F7CB_11D6_842B_00105CAB078C__INCLUDED_)
