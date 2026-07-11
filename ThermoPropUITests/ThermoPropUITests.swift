//
//  ThermoCalcUITests.swift
//  ThermoCalcUITests
//
//  Created by Islombek Sheraliev on 7/10/26.
//

import XCTest

final class ThermoPropUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        app = XCUIApplication()
        app.launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        app = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // XCUIAutomation Documentation
        // https://developer.apple.com/documentation/xcuiautomation
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    func testFluidSearchAndSelectionFlow() throws {
        // 1. Locate and tap the search bar
        let searchBar = app.otherElements["MainFluidSearchBar"].searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 2.0), "Fluid search bar should exist")
        searchBar.tap()
        
        // 2. Type "Water" into the search bar
        searchBar.typeText("Water")
        
        // 3. Locate the search results table view
        let searchResultsTable = app.tables["FluidSearchTableView"]
        XCTAssertTrue(searchResultsTable.waitForExistence(timeout: 2.0), "Search results table should appear")
        
        // Find the cell containing "Water" and tap it
        let waterCell = searchResultsTable.cells.staticTexts["Water"]
        XCTAssertTrue(waterCell.exists, "Water should be visible in the search results")
        waterCell.tap()
        
        // 4. Verify that the search view dismisses and returns to the main calculator view
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 2.0), "Main scroll view should return after selection")
        
        // 5. Verify that the grid characteristics have updated from "0" to actual numbers
        // We can target the specific text values of the updated characteristics cards
        let molarWeightText = app.staticTexts["18.0153"] // Water's molar weight value
        let criticalTemperatureText = app.staticTexts["647.0960"] // Water's critical temperature value
        
        XCTAssertTrue(molarWeightText.waitForExistence(timeout: 2.0), "Grid should display Water's molar weight")
        XCTAssertTrue(criticalTemperatureText.exists, "Grid should display Water's critical temperature")
    }
    
    func testEndResultAfterFluidSelection() throws {
        // 1. Choose Fluid first
        let searchBar = app.otherElements["MainFluidSearchBar"].searchFields.firstMatch
        searchBar.tap()
        searchBar.typeText("Water")
        app.tables["FluidSearchTableView"].cells.staticTexts["Water"].tap()
        
        // 2. Tap State Point calculator option now that a fluid is active
        let statePointMenuOption = app.staticTexts["State point"]
        XCTAssertTrue(statePointMenuOption.exists)
        statePointMenuOption.tap()
        
        // 3. Enter values and calculate
        let firstInput = app.textFields["StatePointInput1"]
        let secondInput = app.textFields["StatePointInput2"]
        
        firstInput.tap()
        firstInput.typeText("300")
        
        secondInput.tap()
        secondInput.typeText("0.1")
        
        // Tap background to dismiss keyboard
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1)).tap()
        
        // Trigger calculation
        app.buttons["Calculate State"].tap()
        
        // 4. Verify results unhide successfully
        let segmentedControl = app.segmentedControls.firstMatch
        XCTAssertTrue(segmentedControl.waitForExistence(timeout: 3.0), "Results grid should appear")
    }
    
    func testSaturationTableCalculationFlow() throws {
        // 1. Select the fluid first (Required before clicking a calculator)
        let searchBar = app.otherElements["MainFluidSearchBar"].searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 2.0))
        searchBar.tap()
        searchBar.typeText("Water")
        app.tables["FluidSearchTableView"].cells.staticTexts["Water"].tap()
        
        // 2. Navigate to Saturation Table screen
        let saturationMenuOption = app.staticTexts["Saturation table"]
        XCTAssertTrue(saturationMenuOption.waitForExistence(timeout: 2.0), "Saturation table option should exist")
        saturationMenuOption.tap()
        
        // Verify navigation succeeded
        let navBar = app.navigationBars["Saturation table"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 2.0), "Should navigate to Saturation Table screen")
        
        // 3. Locate the input fields using your accessibility identifiers
        let fromInput = app.textFields["SaturationFromInput"]
        let toInput = app.textFields["SaturationToInput"]
        let stepInput = app.textFields["SaturationStepInput"]
        
        XCTAssertTrue(fromInput.exists)
        XCTAssertTrue(toInput.exists)
        XCTAssertTrue(stepInput.exists)
        
        // 4. Input range parameters (e.g., Temperature 300K to 400K with a step of 10)
        fromInput.tap()
        fromInput.typeText("300")
        
        toInput.tap()
        toInput.typeText("400")
        
        stepInput.tap()
        stepInput.typeText("10")
        
        // Dismiss the keyboard by tapping the background area
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1)).tap()
        
        // 5. Tap the primary generation button
        // Matches the title: "Generate table" from SaturationTableViewConroller
        let generateButton = app.buttons["Generate table"]
        XCTAssertTrue(generateButton.exists, "Generate table button should exist")
        generateButton.tap()
        
        // 6. Verify that the table grid successfully populates and unhides
        let segmentedControl = app.segmentedControls.firstMatch
        XCTAssertTrue(segmentedControl.waitForExistence(timeout: 5.0), "Results grid segmented control should appear")
        
        let transportTab = segmentedControl.buttons["Transport"]
        XCTAssertTrue(transportTab.exists, "Transport tab segment should be visible")
    }
    
    func testIsoProcessTableCalculationFlow() throws {
        // 1. Select the fluid first (Required before clicking a calculator)
        let searchBar = app.otherElements["MainFluidSearchBar"].searchFields.firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: 2.0))
        searchBar.tap()
        searchBar.typeText("Water")
        app.tables["FluidSearchTableView"].cells.staticTexts["Water"].tap()
        
        // 2. Navigate to Iso-Process Table screen
        let isoProcessMenuOption = app.staticTexts["Iso-process table"]
        XCTAssertTrue(isoProcessMenuOption.waitForExistence(timeout: 2.0), "Iso-process table option should exist")
        isoProcessMenuOption.tap()
        
        // Verify navigation succeeded by checking the navigation bar title
        let navBar = app.navigationBars["Iso-process table"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 2.0), "Should navigate to Iso-process Table screen")
        
        // 3. Locate the input fields using your accessibility identifiers
        let fixedInput = app.textFields["IsoFixedInput"]
        let fromInput = app.textFields["IsoFromInput"]
        let toInput = app.textFields["IsoToInput"]
        let stepInput = app.textFields["IsoStepInput"]
        
        XCTAssertTrue(fixedInput.exists, "Fixed parameter text field should be present")
        XCTAssertTrue(fromInput.exists, "From text field should be present")
        XCTAssertTrue(toInput.exists, "To text field should be present")
        XCTAssertTrue(stepInput.exists, "Step text field should be present")
        
        // 4. Input process parameters (e.g., Pressure fixed at 0.1 MPa, Temperature range 300K to 400K, step 10)
        fixedInput.tap()
        fixedInput.typeText("0.1")
        
        fromInput.tap()
        fromInput.typeText("300")
        
        toInput.tap()
        toInput.typeText("400")
        
        stepInput.tap()
        stepInput.typeText("10")
        
        // Dismiss the keyboard by tapping the background area
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1)).tap()
        
        // 5. Tap the primary generation button
        // Matches the title: "Calculate Process" from ExpandableIsoProcessInputCard
        let calculateButton = app.buttons["Calculate Process"]
        XCTAssertTrue(calculateButton.exists, "Calculate Process button should exist")
        calculateButton.tap()
        
        // 6. Verify that the table grid successfully populates and unhides
        let segmentedControl = app.segmentedControls.firstMatch
        XCTAssertTrue(segmentedControl.waitForExistence(timeout: 5.0), "Results segmented control should appear")
        
        let thermodynamicTab = app.buttons["Thermodynamic"]
        XCTAssertTrue(thermodynamicTab.waitForExistence(timeout: 5.0), "Thermodynamic tab segment button should appear and be visible")
    }
}
