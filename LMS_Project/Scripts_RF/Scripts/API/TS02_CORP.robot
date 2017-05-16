*** Settings ***
Suite Setup       Run Keywords    Create LMS Session    Connect LMS Database
Suite Teardown    Run Keywords    Delete LMS Session    Disconnect From Database
Test Setup
Force Tags        api    corp
Resource          Corp_Keywords.robot
Resource          Login_Keywords.robot
Resource          Common_Keywords.robot

*** Variables ***
${CORP_CODE}      AUTOMATION01
${CORP_NAME}      ${CORP_CODE} added by API Automation
${CIS_ID}         111111111111
${ACTIVE_STATUS}    Y

*** Test Cases ***
Maker Add New Corporation
    Login    maker    maker
    Add Corporation    ${CORP_CODE}    ${CORP_NAME}    ${CIS_ID}    ${ACTIVE_STATUS}

Checker Reject Pending Corporation
    Login    checker    checker
    Reject Corporation    ${CORP_CODE}

Maker Edit Pending Corporation
    Login    maker    maker
    Edit Corporation    ${CORP_CODE}    ${CORP_CODE} edited by API Automation    ${CIS_ID}    ${ACTIVE_STATUS}

Checker Approve Add Corporation
    Login    checker    checker
    Approve Add Corporation    ${CORP_CODE}    N

Maker Delete Corporation
    Login    maker    maker
    Delete Corporation    ${CORP_CODE}

Checker Approve Delete Corporation
    Login    checker    checker
    Approve Delete Corporation    ${CORP_CODE}    D

Maker Cancel Corporation
    Login    maker    maker
    Add Corporation    ${CORP_CODE}    ${CORP_NAME}    ${CIS_ID}    ${ACTIVE_STATUS}
    Login    checker    checker
    Reject Corporation    ${CORP_CODE}
    Login    maker    maker
    Cancel Corporation    ${CORP_CODE}
