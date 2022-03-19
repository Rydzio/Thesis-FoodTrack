@testable import FoodTrack
import XCTest
import Firebase

class FoodTrackTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testFilterItemsBySearchText() throws {
        
        let searchText = "ml"
        let selectedScope = 0
        
        let item1 = Item(itemName: "Mleko", itemID: "1", userID: "1", groupID: "1", creationDate: 123123123, isDone: false, type: Constant.scopeTable[0], expiryDate: 2532443534)
        let item2 = Item(itemName: "kokos", itemID: "1", userID: "1", groupID: "1", creationDate: 123123123, isDone: false, type: Constant.scopeTable[0], expiryDate: 2532443534)
        let item3 = Item(itemName: "mleko kokosowe", itemID: "1", userID: "1", groupID: "1", creationDate: 123123123, isDone: false, type: Constant.scopeTable[0], expiryDate: 2532443534)
        
        
        
        let items: [Item] = [item1, item2, item3]
        let expectedFilteredItems: [Item] = [item1, item3]
        
        // filterItems
        let filteredItems = ItemsTableViewController.doFilterItems(searchWith: searchText, selectedScope: selectedScope, items: items)
        
        // filteredItems == expectedFilteredItems
        XCTAssert(filteredItems.elementsEqual(expectedFilteredItems))
    }

    func testFilterItemsBySelectedScope() throws {
        
        let searchText = ""
        let selectedScope = 1
        
        let item1 = Item(itemName: "Mleko", itemID: "1", userID: "1", groupID: "1", creationDate: 123123123, isDone: false, type: Constant.scopeTable[0], expiryDate: 2532443534)
        let item2 = Item(itemName: "kokos", itemID: "1", userID: "1", groupID: "1", creationDate: 123123123, isDone: false, type: Constant.scopeTable[1], expiryDate: 2532443534)
        let item3 = Item(itemName: "mleko kokosowe", itemID: "1", userID: "1", groupID: "1", creationDate: 123123123, isDone: false, type: Constant.scopeTable[0], expiryDate: 2532443534)
        
        
        
        let items: [Item] = [item1, item2, item3]
        let expectedFilteredItems: [Item] = [item2]
        
        // filterItems
        let filteredItems = ItemsTableViewController.doFilterItems(searchWith: searchText, selectedScope: selectedScope, items: items)
        
        // filteredItems == expectedFilteredItems
        XCTAssert(filteredItems.elementsEqual(expectedFilteredItems))
    }

    func testFilterItemsBySearchTeextAndSelectedScope() throws {
        
        let searchText = "ml"
        let selectedScope = 1
        
        let item1 = Item(itemName: "Mleko", itemID: "1", userID: "1", groupID: "1", creationDate: 123123123, isDone: false, type: Constant.scopeTable[0], expiryDate: 2532443534)
        let item2 = Item(itemName: "kokos", itemID: "1", userID: "1", groupID: "1", creationDate: 123123123, isDone: false, type: Constant.scopeTable[1], expiryDate: 2532443534)
        let item3 = Item(itemName: "mleko kokosowe", itemID: "1", userID: "1", groupID: "1", creationDate: 123123123, isDone: false, type: Constant.scopeTable[1], expiryDate: 2532443534)
        
        
        
        let items: [Item] = [item1, item2, item3]
        let expectedFilteredItems: [Item] = [item3]
        
        // filterItems
        let filteredItems = ItemsTableViewController.doFilterItems(searchWith: searchText, selectedScope: selectedScope, items: items)
        
        // filteredItems == expectedFilteredItems
        XCTAssert(filteredItems.elementsEqual(expectedFilteredItems))
    }
    
    func testFilterItemsByNoCriteria() throws {
        
        let searchText = ""
        let selectedScope = 0
        
        let item1 = Item(itemName: "Mleko", itemID: "1", userID: "1", groupID: "1", creationDate: 123123123, isDone: false, type: Constant.scopeTable[0], expiryDate: 2532443534)
        let item2 = Item(itemName: "kokos", itemID: "1", userID: "1", groupID: "1", creationDate: 123123123, isDone: false, type: Constant.scopeTable[0], expiryDate: 2532443534)
        let item3 = Item(itemName: "mleko kokosowe", itemID: "1", userID: "1", groupID: "1", creationDate: 123123123, isDone: false, type: Constant.scopeTable[0], expiryDate: 2532443534)
        
        
        
        let items: [Item] = [item1, item2, item3]
        let expectedFilteredItems: [Item] = [item1, item2, item3]
        
        // filterItems
        let filteredItems = ItemsTableViewController.doFilterItems(searchWith: searchText, selectedScope: selectedScope, items: items)
        
        // filteredItems == expectedFilteredItems
        XCTAssert(filteredItems.elementsEqual(expectedFilteredItems))
    }
    
    func testFilterItemsNoItemsFittingCryteria() throws {
        
        let searchText = "Ml"
        let selectedScope = 1
        
        let item1 = Item(itemName: "Mleko", itemID: "1", userID: "1", groupID: "1", creationDate: 123123123, isDone: false, type: Constant.scopeTable[0], expiryDate: 2532443534)
        let item2 = Item(itemName: "kokos", itemID: "1", userID: "1", groupID: "1", creationDate: 123123123, isDone: false, type: Constant.scopeTable[1], expiryDate: 2532443534)
        let item3 = Item(itemName: "mleko kokosowe", itemID: "1", userID: "1", groupID: "1", creationDate: 123123123, isDone: false, type: Constant.scopeTable[0], expiryDate: 2532443534)
        
        
        
        let items: [Item] = [item1, item2, item3]
        let expectedFilteredItems: [Item] = []
        
        // filterItems
        let filteredItems = ItemsTableViewController.doFilterItems(searchWith: searchText, selectedScope: selectedScope, items: items)
        
        // filteredItems == expectedFilteredItems
        XCTAssert(filteredItems.elementsEqual(expectedFilteredItems))
    }

}
