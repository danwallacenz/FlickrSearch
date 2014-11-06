/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class MasterViewController: UIViewController {
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var searchBar: UISearchBar!
  
    
    // Maps String, the search term, to an array of Flickr.Photo, or the photos returned from the Flickr API.
  var searches = OrderedDictionary<String, [Flickr.Photo]>()

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
        
        if let indexPath = self.tableView.indexPathForSelectedRow()
        {
            // Indicate with the underscore that this part of the tuple doesn’t need to be bound to a local variable.
            let (_, photos) = self.searches[indexPath.row]
            
            (segue.destinationViewController
                as DetailViewController).photos = photos
        }
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if let selectedIndexPath = self.tableView.indexPathForSelectedRow() {
      self.tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
    }
    
    // Deleting searches
    self.navigationItem.leftBarButtonItem = self.editButtonItem()
  }
    
    override func setEditing(editing: Bool, animated: Bool){
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
}




extension MasterViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.searches.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
    
    let (term, photos) = self.searches[indexPath.row]
    cell.textLabel.text = "\(term) (\(photos.count))"
    
    return cell
  }
  
  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    
    if editingStyle == .Delete {
        self.searches.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths(
            [indexPath], withRowAnimation: .Fade)
    }
  }
  
}

extension MasterViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar!) {

    searchBar.resignFirstResponder()
    
    let searchTerm = searchBar.text
    
    // The search method of Flickr takes both a search term and a closure to execute on success or failure of the search.
    // The closure takes one parameter: an enumeration of either Error or Results.
    Flickr.search(searchTerm){
        
        switch ($0) {
            
            // Could make it show an alert here if you wanted, but let’s keep this simple for now. The code requires a break here to tell Swift’s compiler of your intention that the error case do nothing.
            case .Error:
                break
                
            // If the search works, search returns the results as the associated value in the SearchResults enum type. You add the results to the top of the ordered dictionary, with the search term as the key. If the search term already exists in the dictionary, this will bring the search term to the top of the list and update it with the latest results.
            case .Results(let results):
                self.searches.insert(results,
                        forKey: searchTerm,
                        atIndex: 0)
            
            self.tableView.reloadData()
        }
    }
    
  }
  
}
















