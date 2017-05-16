*** Settings ***
Library           DatabaseLibrary
Library           RequestsLibrary
Library           Collections

*** Keywords ***
Add Client
    [Arguments]    ${corp_code}    ${client_code}    ${client_name}    ${cis_id}
    Comment    Verify Client Code Does Not Exist    ${client_code}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${data}=    Set Variable    {"mode":"ADD","type":"P","clientMst":{"corpCode":"${corp_code}","clientCode":"${client_code}","clientName":"${client_name}","cisId":"${cis_id}","activeStatus":"Y","operationFlag":"N"}}
    ${response}=    Post Request    lms_front_api    /apis/client/saveClient    data=${data}    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Log    ${msg}
    Should Be Equal As Integers    ${msg}    1
    Check If Exists In Database    select CLIENT_CODE from CLIENT_TMP where CORP_CODE="${corp_code}" and CLIENT_CODE="${client_code}" and CLIENT_NAME = "${client_name}" and CIS_ID="${cis_id}" and ACTIVE_STATUS="${active_status}" and OPERATION_FLAG="N" and AUTHORIZE_STATUS="W"

Added Client Show In Pending Page
    [Arguments]    ${expected_client_code}    ${expected_client_name}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${data}=    Set Variable    {"draw":1,"columns":[{"data":"clientCode","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"clientCode","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"clientName","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"corpCode","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"authorizeStatus","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"clientCode","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}}],"order":[{"column":0,"dir":"asc"}],"start":0,"length":10,"search":{"value":"","regex":false},"dataSearch":{}}
    ${response}=    Post Request    lms_front_api    /apis/client/searchClientPending    headers=${header}    data=${data}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    @{datas}=    Set Variable    ${msg["data"]}
    Log    ${datas}
    ${datas_length}=    Get Length    ${datas}
    : FOR    ${data}    IN    @{datas}
    \    ${client_code}=    Get From Dictionary    ${data}    clientCode
    \    ${client_name}=    Get From Dictionary    ${data}    clientName
    \    Run Keyword If    '${client_code}'=='${expected_client_code}' and '${client_name}' == '${expected_client_name}'    Exit For Loop

Approve Add Client
    [Arguments]    ${client_code}    ${operation_flag}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${response}=    Get Request    lms_front_api    /apis/client/approveClientByClientCode/${client_code}/${operation_flag}?_=P    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Check If Not Exists In Database    select CLIENT_CODE from CLIENT_TMP where CLIENT_CODE="${client_code}"
    Check If Exists In Database    select CLIENT_CODE from CLIENT_MST where CLIENT_CODE="${client_code}" and ACTIVE_STATUS="Y" and OPERATION_FLAG="${operation_flag}" and AUTHORIZE_STATUS="Y"

Approve Delete Client
    [Arguments]    ${client_code}    ${operation_flag}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${response}=    Get Request    lms_front_api    /apis/client/approveClientByClientCode/${client_code}/${operation_flag}?_=P    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Check If Not Exists In Database    select CLIENT_CODE from CLIENT_TMP where CLIENT_CODE="${client_code}"
    Check If Not Exists In Database    select CLIENT_CODE from CLIENT_MST where CLIENT_CODE="${client_code}"

Cancel Client
    [Arguments]    ${client_code}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${response}=    Get Request    lms_front_api    /apis/client/cancelClientByClientCode/${client_code}?_=P    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg}    1
    Check If Not Exists In Database    select CLIENT_CODE from CLIENT_TMP where CLIENT_CODE="${client_code}"
    Check If Not Exists In Database    select CLIENT_CODE from CLIENT_MST where CLIENT_CODE="${client_code}"

Delete Client
    [Arguments]    ${client_code}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${response}=    Get Request    lms_front_api    /apis/client/deleteClientByClientCode/${client_code}?_=A    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg}    1
    Check If Exists In Database    select CLIENT_CODE from CLIENT_TMP where CLIENT_CODE="${client_code}" and ACTIVE_STATUS="Y" and OPERATION_FLAG="D" and AUTHORIZE_STATUS="W"
    Check If Exists In Database    select CLIENT_CODE from CLIENT_MST where CLIENT_CODE="${client_code}" and ACTIVE_STATUS="Y" and AUTHORIZE_STATUS="Y" and OPERATION_FLAG="N"

Edit Client
    [Arguments]    ${corp_code}    ${client_code}    ${client_name}    ${cis_id}    ${active_status}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${data}=    Set Variable    {"mode":"EDIT","type":"P","clientMst":{"corpCode":"${corp_code}","clientCode":"${client_code}","clientName":"${client_name}","cisId":"${cis_id}","activeStatus":"${active_status}","operationFlag":"N"}}
    ${response}=    Post Request    lms_front_api    /apis/client/saveClient    data=${data}    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg}    1
    Check If Exists In Database    select CLIENT_CODE from CLIENT_TMP where CORP_CODE="${corp_code}" and CLIENT_CODE="${client_code}" and CLIENT_NAME = "${client_name}" and CIS_ID="${cis_id}" and ACTIVE_STATUS="${active_status}" and OPERATION_FLAG="N" and AUTHORIZE_STATUS="W"

Reject Client
    [Arguments]    ${client_code}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${data}=    Set Variable    {"rejectReason":"Rejected By Automation Script","clientCode":"${client_code}","operationFlag":"N"}
    ${response}=    Post Request    lms_front_api    /apis/client/rejectClientByClientCode    data=${data}    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg}    1
    Check If Exists In Database    select CLIENT_CODE from CLIENT_TMP where CLIENT_CODE="${client_code}" and AUTHORIZE_STATUS="N"

Verify Client Code Does Not Exist
    [Arguments]    ${client_code}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}
    ${response}=    Get Request    lms_front_api    /apis/client/checkClientDuplicate/${client_code}?_=P    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg}    0
