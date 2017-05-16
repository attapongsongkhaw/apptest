*** Settings ***
Library           DatabaseLibrary
Library           RequestsLibrary
Library           Collections

*** Keywords ***
Add Corporation
    [Arguments]    ${corp_code}    ${corp_name}    ${cis_id}    ${active_status}
    Verify Corporation Code Does Not Exist    ${corp_code}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${data}=    Set Variable    {"mode":"ADD","corporationMst":{"corpCode":"${corp_code}","corpName":"${corp_name}","cisId":"${cis_id}","activeStatus":"${active_status}","operationFlag":"N"},"savingAccount":{"accountNo":"0000000000","accountNameTh":"SAAutomation","accountNameEn":"SAAutomation","cisId":"111111111111","accountLevel":"00","activeStatus":"Y","operationFlag":"N"},"currentAccount":{"accountNo":"7451000033","accountNameTh":"CAAutomate","accountNameEn":"CAAutomate","cisId":"111111111111","accountLevel":"01","activeStatus":"Y","operationFlag":"N"}}
    ${response}=    Post Request    lms_front_api    /apis/corporation/saveCorporation    data=${data}    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg}    1
    Check If Exists In Database    select CORP_CODE from CORPORATION_TMP where CORP_CODE="${corp_code}" and CORP_NAME="${corp_name}" and CIS_ID="${cis_id}" and ACTIVE_STATUS="${active_status}" and OPERATION_FLAG="N" and AUTHORIZE_STATUS="W"

Added Corporation Show In Pending Page
    [Arguments]    ${expected_corp_code}    ${expected_corp_name}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${data}=    Set Variable    {"draw":1,"columns":[{"data":"corpCode","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"corpCode","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"corpName","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"authorizeStatus","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"corpCode","name":"","searchable":true,"orderable":false,"search":{"value":"","regex":false}}],"order":[{"column":0,"dir":"asc"}],"start":0,"length":10,"search":{"value":"","regex":false},"dataSearch":{}}
    ${response}=    Post Request    lms_front_api    /apis/corporation/searchCorporationPending    headers=${header}    data=${data}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    @{datas}=    Set Variable    ${msg["data"]}
    ${datas_length}=    Get Length    ${datas}
    : FOR    ${data}    IN    @{datas}
    \    ${corp_code}=    Get From Dictionary    ${data}    corpCode
    \    ${corp_name}=    Get From Dictionary    ${data}    corpName
    \    Run Keyword If    '${corp_code}'=='${expected_corp_code}' and '${corp_name}' == '${expected_corp_name}'    Exit For Loop

Approve Add Corporation
    [Arguments]    ${corp_code}    ${operation_flag}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${response}=    Get Request    lms_front_api    /apis/corporation/approveCorporationByCorpCode/${corp_code}/${operation_flag}?_=P    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg}    1
    Check If Not Exists In Database    select CORP_CODE from CORPORATION_TMP where CORP_CODE="${corp_code}"
    Check If Exists In Database    select CORP_CODE from CORPORATION_MST where CORP_CODE="${corp_code}" and ACTIVE_STATUS="Y" and OPERATION_FLAG="${operation_flag}" and AUTHORIZE_STATUS="Y"

Approve Delete Corporation
    [Arguments]    ${corp_code}    ${operation_flag}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${response}=    Get Request    lms_front_api    /apis/corporation/approveCorporationByCorpCode/${corp_code}/${operation_flag}?_=P    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg}    1
    Check If Not Exists In Database    select CORP_CODE from CORPORATION_TMP where CORP_CODE="${corp_code}"
    Check If Not Exists In Database    select CORP_CODE from CORPORATION_MST where CORP_CODE="${corp_code}"

Cancel Corporation
    [Arguments]    ${corp_code}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${response}=    Get Request    lms_front_api    /apis/corporation/cancelCorporationByCorpCode/${corp_code}?_=P    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg}    1
    Check If Not Exists In Database    select CORP_CODE from CORPORATION_TMP where CORP_CODE="${corp_code}"
    Check If Not Exists In Database    select CORP_CODE from CORPORATION_MST where CORP_CODE="${corp_code}"

Delete Corporation
    [Arguments]    ${corp_code}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${response}=    Get Request    lms_front_api    /apis/corporation/deleteCorporationByCorpCode/${corp_code}?=A    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg}    1
    Check If Exists In Database    select CORP_CODE from CORPORATION_TMP where CORP_CODE="${corp_code}" and ACTIVE_STATUS="Y" and OPERATION_FLAG="D" and AUTHORIZE_STATUS="W"
    Check If Exists In Database    select CORP_CODE from CORPORATION_MST where CORP_CODE="${corp_code}" and ACTIVE_STATUS="Y" and AUTHORIZE_STATUS="Y" and OPERATION_FLAG="N"

Edit Corporation
    [Arguments]    ${corp_code}    ${corp_name}    ${cis_id}    ${active_status}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${data}=    Set Variable    {"mode":"EDIT","type":"P","corporationMst":{"corpCode":"AUTOMATION01","corpName":"${corp_name}","cisId":"111111111111","activeStatus":"Y","operationFlag":"N"},"savingAccount":{"accountNo":"0000000000","accountNameTh":"SAAutomation","accountNameEn":"SAAutomation","cisId":"111111111111","accountLevel":"00","activeStatus":"Y","operationFlag":"N"},"currentAccount":{"accountNo":"7451000033","accountNameTh":"CAAutomate","accountNameEn":"CAAutomate","cisId":"111111111111","accountLevel":"01","activeStatus":"Y","operationFlag":"N"}}
    ${response}=    Post Request    lms_front_api    /apis/corporation/saveCorporation    data=${data}    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg}    1
    Check If Exists In Database    select CORP_CODE from CORPORATION_TMP where CORP_CODE="${corp_code}" and CORP_NAME="${corp_name}" and CIS_ID="${cis_id}" and ACTIVE_STATUS="${active_status}" and OPERATION_FLAG="N" and AUTHORIZE_STATUS="W"

Reject Corporation
    [Arguments]    ${corp_code}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${data}=    Set Variable    {"rejectReason":"Rejected By Automation Script","corpCode":"${corp_code}","operationFlag":"N"}
    ${response}=    Post Request    lms_front_api    /apis/corporation/rejectCorporationByCorpCode    data=${data}    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg}    1
    Check If Exists In Database    select CORP_CODE from CORPORATION_TMP where CORP_CODE="${corp_code}" and AUTHORIZE_STATUS="N"

Search Active Corporation
    [Arguments]    ${corp_code}    ${corp_name}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${data}=    Set Variable    {"draw":1,"columns":[{"data":"no","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"corpCode","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"corpName","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"authorizeStatus","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"action","name":"","searchable":true,"orderable":false,"search":{"value":"","regex":false}}],"order":[{"column":0,"dir":"asc"}],"start":0,"length":10,"search":{"value":"","regex":false},"dataSearch":{"corpCode":"${corp_code}","corpName":"${corp_name}","authorizeStatus":""}}
    ${response}=    Post Request    lms_front_api    /apis/corporation/searchCorporationActive    headers=${header}    data=${data}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg["recordsTotal"]}    1

Search Pending Corporation
    [Arguments]    ${corp_code}    ${corp_name}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${data}=    Set Variable    {"draw":1,"columns":[{"data":"no","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"corpCode","name":"${corp_name}","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"corpName","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"authorizeStatus","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"action","name":"","searchable":true,"orderable":false,"search":{"value":"","regex":false}}],"order":[{"column":0,"dir":"asc"}],"start":0,"length":10,"search":{"value":"","regex":false},"dataSearch":{"corpCode":"${corp_code}","corpName":"${corp_name}","authorizeStatus":""}}
    ${response}=    Post Request    lms_front_api    /apis/corporation/searchCorporationPending    headers=${header}    data=${data}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg["recordsTotal"]}    1

Test Connect Database
    Connect To Database    pymysql    lms    lmsdb    P@ssw0rd    172.30.141.84    3306
    Table Must Exist    CORPORATION_MST
    Comment    Execute Sql String    insert into MyGuests (firstname, lastname) values ("Patrawadee", "Youyen")
    @{queryResutl}    Query    select * from CORPORATION_MST
    Log Many    @{queryResutl}
    Comment    Check If Exists In Database    select * from MyGuests where firstname="Patrawadee" and lastname ="Youyen" and email IS NULL
    Comment    Execute Sql String    delete from MyGuests where firstname="Patrawadee" and lastname ="Youyen" and email IS NULL;
    Disconnect From Database

Verify Corporation Code Does Not Exist
    [Arguments]    ${corp_code}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}
    ${response}=    Get Request    lms_front_api    /apis/corporation/checkCorpDuplicate/${corp_code}    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg}    0
