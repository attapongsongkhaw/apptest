*** Settings ***
Suite Setup       Run Keywords    Create LMS Session    Connect LMS Database    Add Temp Corp and Client
Suite Teardown    Run Keywords    Delete Temp Corp and Client    Delete LMS Session    Disconnect From Database
Force Tags        api    account
Resource          Client_Keywords.robot
Resource          Login_Keywords.robot
Resource          Corp_Keywords.robot
Resource          Client_Keywords.robot
Resource          Account_Keywords.robot
Resource          Common_Keywords.robot

*** Variables ***
${CORP_CODE}      AUTOMATION01
${CORP_NAME}      ${CORP_CODE} added by API Automation
${CLIENT_CODE}    ${CORP_CODE}_CLIENT
${CLIENT_NAME}    ${CLIENT_CODE} added by API Automation
${CIS_ID}         111111111111
${ACTIVE_STATUS}    Y
${ACCOUNT_NO}     0111111111

*** Test Cases ***
Maker Add New Account
    Login    maker    maker
    Verify Account Does Not Exist    ${ACCOUNT_NO}
    Get Account Detail By Account Number    ${ACCOUNT_NO}
    Add Account    ${CORP_CODE}    ${CLIENT_CODE}    ${ACCOUNT_NO}    ${ACCOUNT_NAME_EN}    ${ACCOUNT_NAME_TH}    ${KBANK_PRODUCTPCODE}
    ...    ${CIS_ID}

Checker Reject Pending Account
    Login    checker    checker
    Search Pending Account    ${ACCOUNT_NO}
    Reject Account    ${ACCOUNT_ID}

Maker Edit Account
    Login    maker    maker
    Search Pending Account    ${ACCOUNT_NO}
    Get Account Detail By Account Number    ${ACCOUNT_NO}
    Edit Account    ${ACCOUNT_ID}    ${CORP_CODE}    ${CLIENT_CODE}    ${CIS_ID}    ${ACCOUNT_NO}    ${ACCOUNT_NAME_EN}
    ...    ${ACCOUNT_NAME_TH}    ${KBANK_PRODUCTPCODE}

Checker Approve Account
    Login    checker    checker
    Search Pending Account    ${ACCOUNT_NO}
    Approve Add Account    ${ACCOUNT_ID}    N

Maker Delete Account
    Login    maker    maker
    Search Active Account    ${ACCOUNT_NO}
    Delete Account    ${ACCOUNT_ID}

Checker Approve Delete Account
    Login    maker    maker
    Search Pending Account    ${ACCOUNT_NO}
    Approve Delete Account    ${ACCOUNT_ID}    D

Maker Cancel Account
    Login    maker    maker
    Verify Account Does Not Exist    ${ACCOUNT_NO}
    Get Account Detail By Account Number    ${ACCOUNT_NO}
    Add Account    ${CORP_CODE}    ${CLIENT_CODE}    ${ACCOUNT_NO}    ${ACCOUNT_NAME_EN}    ${ACCOUNT_NAME_TH}    ${KBANK_PRODUCTPCODE}
    ...    ${CIS_ID}
    Login    checker    checker
    Search Pending Account    ${ACCOUNT_NO}
    Reject Account    ${ACCOUNT_ID}
    Login    maker    maker
    Search Pending Account    ${ACCOUNT_NO}
    Cancel Account    ${ACCOUNT_ID}

*** Keywords ***
Add Temp Corp and Client
    Login    maker    maker
    Add Corporation    ${CORP_CODE}    ${CORP_NAME}    ${CIS_ID}    ${ACTIVE_STATUS}
    Login    checker    checker
    Approve Add Corporation    ${CORP_CODE}    N
    Login    maker    maker
    Add Client    ${CORP_CODE}    ${CLIENT_CODE}    ${CLIENT_NAME}    ${CIS_ID}
    Login    checker    checker
    Approve Add Client    ${CLIENT_CODE}    N

Delete Temp Corp and Client
    Login    maker    maker
    Delete Client    ${CLIENT_CODE}
    Login    checker    checker
    Approve Delete Client    ${CLIENT_CODE}    D
    Login    maker    maker
    Delete Corporation    ${CORP_CODE}
    Login    checker    checker
    Approve Delete Corporation    ${CORP_CODE}    D
