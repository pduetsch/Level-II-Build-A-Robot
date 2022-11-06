*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

# https://robocorp.com/docs/courses/build-a-robot
Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive
Library             OperatingSystem
Library             RPA.Dialogs
Library             RPA.Robocorp.Vault


*** Variables ***
# Directories
${out_dir}              ${OUTPUT_DIR}${/}
${screenshot_dir}       ${OUTPUT_DIR}${/}Screenshots${/}
${reciept_dir}          ${OUTPUT_DIR}${/}Reciepts${/}

# Website URL
#${url}    https://robotsparebinindustries.com/#/robot-order

# Order file URL
${url_csv}              https://robotsparebinindustries.com/orders.csv


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    # No input dialog
    # ${orders}=    Get orders no input
    # With input dialog
    ${order_file_csv}=    Request URL for CSV from user
    ${orders}=    Get orders    ${order_file_csv}
    FOR    ${order}    IN    @{orders}
        Close modal
        Fill the form    ${order}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${order}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${order}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create ZIP file of all receipts
    Close browser and cleanup


*** Keywords ***
Open the robot order website
    # Open Available Browser    ${url}
    ${secret}=    Get Secret    robo_order_url
    Open Available Browser    ${secret}[url_order_website]
    Maximize Browser Window

Request URL for CSV from user
    [Documentation]    Request the CSV-File URL from the user using a Dialogs
    Add heading    Enter order file URL
    Add text    Please provide the complete URL in order to download the order file csv
    Add text input    url    label=URL for the order file
    ${dialog}=    Run dialog
    RETURN    ${dialog.url}

Get orders no input
    [Documentation]    Download the order CSV file and return table
    Download    ${url_csv}    overwrite=True
    ${orders}=    Read table from CSV    orders.csv
    RETURN    ${orders}

Get orders
    [Documentation]    Download the order CSV file and return table
    [Arguments]    ${order_file_csv}
    Download    ${order_file_csv}    overwrite=True
    ${orders}=    Read table from CSV    orders.csv
    RETURN    ${orders}

Close modal
    Click Element If Visible    //button[@class='btn btn-dark' and contains(text(), "OK")]

Fill the form
    [Arguments]    ${order}
    Select From List By Value    id:head    ${order}[Head]
    Click Element    id:id-body-${order}[Body]
    Input Text    xpath://input[@placeholder="Enter the part number for the legs"]    ${order}[Legs]
    Input Text    id:address    ${order}[Address]

Preview the robot
    Click Button    id:preview
    Page Should Contain Element    id:robot-preview-image

Submit the order
    Wait Until Keyword Succeeds    5x    0.5s    Click order button

Click order button
    Click Button    id:order
    Wait Until Page Contains Element    id:order-another    0.55s

Store the receipt as a PDF file
    [Arguments]    ${order_number}
    Set Local Variable    ${file_path}    ${reciept_dir}reciept_order_${order_number}.pdf
    Wait Until Element Is Visible    id:receipt
    ${reciept_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${reciept_html}    ${file_path}
    RETURN    ${file_path}

Take a screenshot of the robot
    [Arguments]    ${order_number}
    Set Local Variable    ${file_path}    ${screenshot_dir}$preview_image_order_${order_number}.png
    Screenshot    id:robot-preview-image    ${file_path}
    RETURN    ${file_path}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    # Open Pdf    ${pdf}
    ${files}=    Create List    ${screenshot}:align=center
    Add Files To Pdf    ${files}    ${pdf}    append:True
    # Close Pdf    ${pdf}

Go to order another robot
    Click Button When Visible    id:order-another

Create ZIP file of all receipts
    ${zip_file_name}=    Set Variable    ${out_dir}RECIEPTS.zip
    Archive Folder With Zip    ${reciept_dir}    ${zip_file_name}

Close browser and cleanup
    Close Browser
    Remove Directory    ${screenshot_dir}    recursive=True
    Remove Directory    ${reciept_dir}    recursive=True
