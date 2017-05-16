*** Settings ***
Library           DatabaseLibrary
Library           RequestsLibrary
Library           Collections

*** Keywords ***
Add Account
    [Arguments]    ${corp_code}    ${client_code}    ${account_no}    ${account_name_en}    ${account_name_th}    ${kbank_product_code}
    ...    ${cis_id}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${data}=    Set Variable    [{"accountNo":"${account_no}","accountNameEn":"${account_name_en}","accountNameTh":"${account_name_th}","kbankProductCode":"${kbank_product_code}","cisId":"${cis_id}","corpCode":"${corp_code}","clientCode":"${client_code}","accountLevel":"03","activeStatus":"Y"}]
    ${response}=    Post Request    lms_front_api    /apis/account/saveMultipleAccount    data=${data}    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg}    1
    Check If Exists In Database    select ACCOUNT_NO from ACCOUNT_TMP where CORP_CODE="${corp_code}" and CLIENT_CODE="${client_code}" and ACCOUNT_NO="${account_no}" and CIS_ID="${cis_id}" and ACTIVE_STATUS="Y" and AUTHORIZE_STATUS="W" and OPERATION_FLAG="N"

Approve Add Account
    [Arguments]    ${account_id}    ${operation_flag}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${response}=    Get Request    lms_front_api    /apis/account/approveAccountById/${account_id}/${operation_flag}?_=P    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Check If Not Exists In Database    select ACCOUNT_NO from ACCOUNT_TMP where ACCOUNT_NO="${ACCOUNT_NO}"
    Check If Exists In Database    select ACCOUNT_NO from ACCOUNT_MST where ACCOUNT_NO="${ACCOUNT_NO}"

Cancel Account
    [Arguments]    ${account_id}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${response}=    Get Request    lms_front_api    /apis/account/cancelAccountById/${account_id}?_=P    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg}    1
    Check If Not Exists In Database    select ACCOUNT_NO from ACCOUNT_TMP where ACCOUNT_NO="${ACCOUNT_NO}"
    Check If Not Exists In Database    select ACCOUNT_NO from ACCOUNT_MST where ACCOUNT_NO="${ACCOUNT_NO}"

Delete Account
    [Arguments]    ${account_id}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${response}=    Get Request    lms_front_api    /apis/account/deleteAccountById/${account_id}?_=A    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg}    1
    Check If Exists In Database    select ACCOUNT_NO from ACCOUNT_TMP where ACCOUNT_NO="${ACCOUNT_NO}" and ACTIVE_STATUS="Y" and AUTHORIZE_STATUS="W" and OPERATION_FLAG="D"
    Check If Exists In Database    select ACCOUNT_NO from ACCOUNT_MST where ACCOUNT_NO="${ACCOUNT_NO}" and ACTIVE_STATUS="Y" and AUTHORIZE_STATUS="Y" and OPERATION_FLAG="N"

Edit Account
    [Arguments]    ${account_id}    ${corp_code}    ${client_code}    ${cis_id}    ${account_no}    ${account_name_en}
    ...    ${account_name_th}    ${kbank_product_code}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${data}=    Set Variable    {"mode":"EDIT","type":"P","accountMst":{"accountId":"${account_id}","corpCode":"${corp_code}","clientCode":"${client_code}","cisId":"${cis_id}","activeStatus":"Y","operationFlag":"N","accountNo":"${account_no}","accountNameEn":"${account_name_en}","accountNameTh":"${account_name_th}","kbankProductCode":"${kbank_product_code}"}}
    ${response}=    Post Request    lms_front_api    /apis/account/saveAccount    data=${data}    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg}    1
    Check If Exists In Database    select ACCOUNT_NO from ACCOUNT_TMP where CORP_CODE="${corp_code}" and CLIENT_CODE="${client_code}" and ACCOUNT_NO="${account_no}" and CIS_ID="${cis_id}" and ACTIVE_STATUS="Y" and AUTHORIZE_STATUS="W" and OPERATION_FLAG="N"

Get Account Detail By Account Number
    [Arguments]    ${account_no}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}
    ${response}=    Get Request    lms_front_api    /apis/account/getAccountDetailByAccountNo/${account_no}?_=P    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    ${data}=    Set Variable    ${msg}
    ${response_account_no}=    Get From Dictionary    ${data}    accountNo
    Should Be Equal    ${response_account_no}    ${account_no}
    ${response_account_name_en}=    Get From Dictionary    ${data}    accountNameEn
    ${response_account_name_th}=    Get From Dictionary    ${data}    accountNameTh
    ${response_kbank_product_code}=    Get From Dictionary    ${data}    kbankProductCode
    ${response_cis_id}=    Get From Dictionary    ${data}    cisId
    Set Suite Variable    ${ACCOUNT_NAME_EN}    ${response_account_name_en}
    Set Suite Variable    ${ACCOUNT_NAME_TH}    ${response_account_name_th}
    Set Suite Variable    ${KBANK_PRODUCTPCODE}    ${response_kbank_product_code}
    Set Suite Variable    ${CIS_ID}    ${response_cis_id}

Reject Account
    [Arguments]    ${account_id}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${data}=    Set Variable    {"rejectReason":"Rejected By Automation Script","accountId":"${account_id}","operationFlag":"N"}
    ${response}=    Post Request    lms_front_api    /apis/account/rejectAccountById    data=${data}    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg}    1
    Check If Exists In Database    select ACCOUNT_ID from ACCOUNT_TMP where ACCOUNT_ID="${account_id}" and ACTIVE_STATUS="Y" and AUTHORIZE_STATUS="N" and OPERATION_FLAG="N"

Search Active Account
    [Arguments]    ${account_no}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${data}=    Set Variable    {"draw":6,"columns":[{"data":"accountId","name":"","searchable":false,"orderable":true,"search":{"value":"","regex":false}},{"data":"accountNo","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"accountNo","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"accountNameEn","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"accountNameTh","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"corpCode","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"clientCode","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"authorizeStatus","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"accountNo","name":"","searchable":true,"orderable":false,"search":{"value":"","regex":false}}],"order":[{"column":5,"dir":"asc"}],"start":0,"length":10,"search":{"value":"","regex":false},"dataSearch":{}}
    ${response}=    Post Request    lms_front_api    /apis/account/searchAccountActive    headers=${header}    data=${data}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    @{datas}=    Set Variable    ${msg["data"]}
    Log    ${datas}
    ${datas_length}=    Get Length    ${datas}
    : FOR    ${data}    IN    @{datas}
    \    ${response_account_no}=    Get From Dictionary    ${data}    accountNo
    \    ${response_account_id}=    Get From Dictionary    ${data}    accountId
    \    Run Keyword If    '${response_account_no}'=='${account_no}'    Set Suite Variable    ${ACCOUNT_ID}    ${response_account_id}

Search Pending Account
    [Arguments]    ${account_no}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${data}=    Set Variable    {"draw":1,"columns":[{"data":"accountId","name":"","searchable":false,"orderable":false,"search":{"value":"","regex":false}},{"data":"accountNo","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"accountNo","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"accountNameEn","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"accountNameTh","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"corpCode","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"clientCode","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"authorizeStatus","name":"","searchable":true,"orderable":true,"search":{"value":"","regex":false}},{"data":"accountNo","name":"","searchable":true,"orderable":false,"search":{"value":"","regex":false}}],"order":[{"column":0,"dir":"desc"}],"start":0,"length":10,"search":{"value":"","regex":false},"dataSearch":{}}
    ${response}=    Post Request    lms_front_api    /apis/account/searchAccountPending    headers=${header}    data=${data}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    @{datas}=    Set Variable    ${msg["data"]}
    Log    ${datas}
    ${datas_length}=    Get Length    ${datas}
    : FOR    ${data}    IN    @{datas}
    \    ${response_account_no}=    Get From Dictionary    ${data}    accountNo
    \    ${response_account_id}=    Get From Dictionary    ${data}    accountId
    \    Run Keyword If    '${response_account_no}'=='${account_no}'    Set Suite Variable    ${ACCOUNT_ID}    ${response_account_id}

Verify Account Does Not Exist
    [Arguments]    ${account_no}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}
    ${response}=    Get Request    lms_front_api    /apis/account/checkAccountDuplicate/${account_no}?_=P    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Should Be Equal As Integers    ${msg}    0

Approve Delete Account
    [Arguments]    ${account_id}    ${operation_flag}
    ${header}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}    Accept=application/json
    ${response}=    Get Request    lms_front_api    /apis/account/approveAccountById/${account_id}/${operation_flag}?_=P    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Check If Not Exists In Database    select ACCOUNT_NO from ACCOUNT_TMP where ACCOUNT_NO="${ACCOUNT_NO}"
    Check If Not Exists In Database    select ACCOUNT_NO from ACCOUNT_MST where ACCOUNT_NO="${ACCOUNT_NO}"
