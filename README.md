# Level-II-Build-A-Robot

The Robocorp course ["Certificate level II: Build a robot"](https://robocorp.com/docs/courses/build-a-robot) assignment which builds a process automation robot in order to completes the orders from the [RobotSpareBin Industries Inc.](https://robotsparebinindustries.com/) website. The robot takes an order input file and processes one order after another. 


## Automation Process

- Open the robot order website
- Request the order file URL from the user using an input dialog
- Download the CSV file
- Read in the orders from the CSV file
- For each order in the file:
  - Close the annoying modal
  - Fill in the order details into the form on the website
  - Preview the robot and take a screenshot of the configured robot
  - Submit the order 
  - Create a receipt PDF with the robot preview image embedded
  - Go to order another robot
- Create a ZIP file of the receipts
- Close the browser
- Clean up
