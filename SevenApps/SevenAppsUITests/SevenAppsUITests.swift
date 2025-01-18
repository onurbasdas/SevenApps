//
//  SevenAppsUITests.swift
//  SevenAppsUITests
//
//  Created by Metin on 18.01.2025.
//

import XCTest

final class SevenAppsUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    override func tearDownWithError() throws {
        // Cleanup if needed
    }

    @MainActor
    func testUserListNavigation() throws {
        // Test if the main view exists
        let userListView = app.otherElements["userListView"]
        XCTAssertTrue(userListView.exists, "User list view should exist")
        
        // Test if table view exists
        let userTable = app.tables["userListTableView"]
        XCTAssertTrue(userTable.exists, "User list table should exist")
        
        // Test if we can tap on first cell
        if userTable.cells.count > 0 {
            let firstCell = userTable.cells["userCell_0"]
            XCTAssertTrue(firstCell.exists, "First cell should exist")
            firstCell.tap()
            
            // Verify navigation to detail view
            let detailView = app.otherElements["userDetailView"]
            XCTAssertTrue(detailView.exists, "Detail view should be visible after tapping cell")
        }
    }
    
    @MainActor
    func testUserDetailView() throws {
        // Navigate to detail view
        let userTable = app.tables["userListTableView"]
        if userTable.cells.count > 0 {
            userTable.cells["userCell_0"].tap()
            
            // Add wait predicates for labels
            let nameLabel = app.staticTexts["nameLabel"]
            let emailLabel = app.staticTexts["emailLabel"]
            let phoneLabel = app.staticTexts["phoneLabel"]
            let websiteLabel = app.staticTexts["websiteLabel"]
            let addressLabel = app.staticTexts["addressLabel"]
            let companyLabel = app.staticTexts["companyLabel"]
            
            // Wait for name label to appear with timeout
            let exists = nameLabel.waitForExistence(timeout: 5)
            XCTAssertTrue(exists, "Name label should appear within 5 seconds")
            
            // Now test other labels
            XCTAssertTrue(emailLabel.exists, "Email label should exist in detail view")
            XCTAssertTrue(phoneLabel.exists, "Phone label should exist in detail view")
            XCTAssertTrue(websiteLabel.exists, "Website label should exist in detail view")
            XCTAssertTrue(addressLabel.exists, "Address label should exist in detail view")
            XCTAssertTrue(companyLabel.exists, "Company label should exist in detail view")
            
            // Verify label contents are not empty
            XCTAssertFalse(nameLabel.label.isEmpty, "Name label should not be empty")
            XCTAssertFalse(emailLabel.label.isEmpty, "Email label should not be empty")
            
            // Test back navigation
            app.navigationBars.buttons.element(boundBy: 0).tap()
            XCTAssertTrue(userTable.exists, "Should navigate back to user list")
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
