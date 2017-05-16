*** Settings ***
Suite Setup       Create LMS Session
Suite Teardown    Delete LMS Session
Force Tags        api    login
Resource          Login_Keywords.robot
Resource          Common_Keywords.robot

*** Test Cases ***
Maker Login Success
    Login    maker    maker

Checker Login Success
    Login    checker    checker
