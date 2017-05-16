*** Settings ***
Library           DatabaseLibrary
Library           RequestsLibrary

*** Keywords ***
Login
    [Arguments]    ${username}    ${password}
    ${header}=    Create Dictionary    Content-Type=application/json    Accept=application/json
    ${data}=    Set Variable    {"username":"${username}","password":"${password}"}
    ${response}=    Post Request    lms_front_api    /login    data=${data}    headers=${header}
    Should Be Equal As Strings    ${response.status_code}    200
    ${msg}=    To json    ${response.content}
    Set Suite Variable    ${TOKEN}    ${msg["token"]}
