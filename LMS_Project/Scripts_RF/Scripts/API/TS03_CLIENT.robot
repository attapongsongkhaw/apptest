*** Settings ***
Suite Setup       Run Keywords    Create LMS Session    Connect LMS Database    Add Temp Corp
Suite Teardown    Run Keywords    Delete Temp Corp    Delete LMS Session    Disconnect From Database
Force Tags        api    client
Resource          Client_Keywords.robot
Resource          Login_Keywords.robot
Resource          Corp_Keywords.robot
Resource          Common_Keywords.robot

*** Variables ***
${CORP_CODE}      AUTOMATION01
${CORP_NAME}      ${CORP_CODE} added by API Automation
${CLIENT_CODE}    ${CORP_CODE}_CLIENT
${CLIENT_NAME}    ${CLIENT_CODE} added by API Automation
${CIS_ID}         111111111111
${ACTIVE_STATUS}    Y

*** Test Cases ***
Maker Add New Client
    Login    maker    maker
    Add Client    ${CORP_CODE}    ${CLIENT_CODE}    ${CLIENT_NAME}    ${CIS_ID}

Checker Reject Pending Client
    Login    checker    checker
    Reject Client    ${CLIENT_CODE}

Maker Edit Pending Client
    Login    maker    maker
    Edit Client    ${CORP_CODE}    ${CLIENT_CODE}    ${CLIENT_CODE} edited by API Automation    ${CIS_ID}    ${ACTIVE_STATUS}

Checker Approve Add Client
    Login    checker    checker
    Approve Add Client    ${CLIENT_CODE}    N

Maker Delete Client
    Login    maker    maker
    Delete Client    ${CLIENT_CODE}

Checker Approve Delete Client
    Login    checker    checker
    Approve Delete Client    ${CLIENT_CODE}    D

Maker Cancel Client
    Login    maker    maker
    Add Client    ${CORP_CODE}    ${CLIENT_CODE}    ${CLIENT_NAME}    ${CIS_ID}
    Login    checker    checker
    Reject Client    ${CLIENT_CODE}
    Login    maker    maker
    Cancel Client    ${CLIENT_CODE}

*** Keywords ***
Add Temp Corp
    Login    maker    maker
    Add Corporation    ${CORP_CODE}    ${CORP_NAME}    ${CIS_ID}    ${ACTIVE_STATUS}
    Login    checker    checker
    Approve Add Corporation    ${CORP_CODE}    N

Delete Temp Corp
    Login    maker    maker
    Delete Corporation    ${CORP_CODE}
    Login    checker    checker
    Approve Delete Corporation    ${CORP_CODE}    D
