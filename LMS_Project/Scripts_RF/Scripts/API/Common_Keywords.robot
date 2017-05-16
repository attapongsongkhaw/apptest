*** Settings ***
Library           DatabaseLibrary
Library           RequestsLibrary

*** Variables ***
#${HOST}          172.30.132.238:8443

*** Keywords ***
Create LMS Session
    Create Session    lms_front_api    https://${HOST}/LMSMasterSetup

Delete LMS Session
    Delete All Sessions

Connect LMS Database
    Connect To Database    pymysql    lms    lmsdb    P@ssw0rd    172.30.141.84    3306

Disconnect LMS Database
    Disconnect From Database
