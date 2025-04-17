//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Федор Чистовский on 23.01.2025.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        func testAuth() {
             app.buttons["loginButton"].tap()
             let webView = app.webViews["webView"]
             
             XCTAssertTrue(webView.waitForExistence(timeout: 5))
             
             let loginTextField = webView.descendants(matching: .textField).element
             XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
             
             loginTextField.tap()
             loginTextField.typeText("")
             webView.swipeUp()
             
             let passwordTextField = webView.descendants(matching: .secureTextField).element
             XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
             
             passwordTextField.tap()
             passwordTextField.typeText("")
             webView.swipeUp()
             
             webView.buttons["Login"].tap()
             
             let tablesQuery = app.tables
             let cell = tablesQuery.cells.element(boundBy: 0)
             
             XCTAssertTrue(cell.waitForExistence(timeout: 5))
         }
       }
       
    func testFeed() {
            sleep(5)
            
            let tablesQuery = app.tables
            let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
            cell.swipeUp()
            app.tables["tableView"].swipeDown()
            
            sleep(2)
            
            let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
            cellToLike.buttons["likeButton"].tap()
            
            sleep(2)
            
            cellToLike.buttons["likeButton"].tap()
            
            sleep(2)
            
            cellToLike.tap()
            
            sleep(3)
            
            let image = app.scrollViews.images.element(boundBy: 0)
            image.pinch(withScale: 3, velocity: 1)
            image.pinch(withScale: 0.5, velocity: -1)
            app.buttons["goBackButton"].tap()
        }
       
    func testProfile() {
         sleep(3)
         app.tabBars.buttons.element(boundBy: 1).tap()
         sleep(1)
         XCTAssertTrue(app.staticTexts[""].exists)
         XCTAssertTrue(app.staticTexts[""].exists)
         app.buttons["logoutButton"].tap()
         app.alerts["Пока!"].buttons["Да"].tap()
         let enterButton = app.buttons["loginButton"]
         XCTAssertTrue(enterButton.waitForExistence(timeout: 2))
     }
    

    
}
