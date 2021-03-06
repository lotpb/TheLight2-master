//
//  ProductController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/8/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase


@available(iOS 13.0, *)
final class ProductVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView?
    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0
    //search
    private var searchController: UISearchController!
    private var resultsController = UITableViewController()
    private var filteredTitles = [ProdModel]()
    private let searchScope = ["product","productNo","active"]
    
    //firebase
    private var prodlist = [ProdModel]()
    private var activeCount: Int?
    private var defaults = UserDefaults.standard
    //parse
    private var _feedItems = NSMutableArray()
    private var _feedheadItems = NSMutableArray()
    
    private var isFormStat = false
    private var selectedImage: UIImage?
    private var pasteBoard = UIPasteboard.general
    
    lazy private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = ColorX.Table.navColor
        refreshControl.tintColor = .white
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true

        setupNavigation()
        loadData()
        setupTableView()
        tableView!.addSubview(refreshControl)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshData(self)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = ColorX.Table.navColor
        //TabBar Hidden
        tabBarController?.tabBar.isHidden = false
        
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(ProductVC.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
        
        setMainNavItems()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        //TabBar Hidden
        tabBarController?.tabBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNavigation() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newData))
        navigationItem.title = "Products"
        self.navigationItem.largeTitleDisplayMode = .always
        
        searchController = UISearchController(searchResultsController: resultsController)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.scopeButtonTitles = searchScope
        searchController.searchBar.sizeToFit()
        searchController.obscuresBackgroundDuringPresentation = false
        self.definesPresentationContext = true
    }
    
    func setupTableView() {
        // MARK: - TableHeader
        tableView?.register(HeaderViewCell.self, forCellReuseIdentifier: "Header")
        
        tableView!.delegate = self
        tableView!.dataSource = self
        tableView!.sizeToFit()
        tableView!.clipsToBounds = true
        let bgView = UIView()
        bgView.backgroundColor = .secondarySystemGroupedBackground
        tableView!.backgroundView = bgView
        tableView!.tableFooterView = UIView(frame: .zero)
  
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserFoundCell")
        resultsController.tableView.backgroundColor = ColorX.LGrayColor
        resultsController.tableView.tableFooterView = UIView(frame: .zero)
        resultsController.tableView.sizeToFit()
        resultsController.tableView.clipsToBounds = true
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self
    }
    
    // MARK: - NavigationController Hidden
    @objc func hideBar(notification: NSNotification)  {
        if UIDevice.current.userInterfaceIdiom == .phone  {
            let state = notification.object as! Bool
            navigationController?.setNavigationBarHidden(state, animated: true)
            UIView.animate(withDuration: 0.2, animations: {
                self.tabBarController?.hideTabBarAnimated(hide: state) //added
            }, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: false)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("hide"), object: true)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.lastContentOffset = scrollView.contentOffset.y;
    }
    
    // MARK: - Refresh
    @objc func refreshData(_ sender:AnyObject) {
        
        prodlist.removeAll() // FIXME: shouldn't crash
        loadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Button
    @objc func newData() {
        isFormStat = true
        self.performSegue(withIdentifier: "prodDetailSegue", sender: self)
    }
    
    // MARK: - Parse
    func loadData() {
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
        let query = PFQuery(className:"Product")
        query.limit = 1000
        query.order(byAscending: "Products")
        query.cachePolicy = .cacheThenNetwork
        query.findObjectsInBackground { objects, error in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedItems = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error")
            }
        }
        
        let query1 = PFQuery(className:"Product")
        query1.whereKey("Active", equalTo:"Active")
        query1.cachePolicy = .cacheThenNetwork
        query1.order(byDescending: "createdAt")
        query1.findObjectsInBackground { objects, error in
            if error == nil {
                let temp: NSArray = objects! as NSArray
                self._feedheadItems = temp.mutableCopy() as! NSMutableArray
                self.tableView!.reloadData()
            } else {
                print("Error")
            }
        }
        } else {
            //firebase
            FirebaseRef.databaseRoot.child("Product").observe(.childAdded , with:{ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                let prodTxt = ProdModel(dictionary: dictionary)
                self.prodlist.append(prodTxt)
                
                self.prodlist.sort(by: { (p1, p2) -> Bool in
                    return p1.products.compare(p2.products) == .orderedAscending
                })
                DispatchQueue.main.async(execute: {
                    self.tableView?.reloadData()
                })
            })
            
            FirebaseRef.databaseRoot.child("Product")
                .queryOrdered(byChild: "active") //inludes reply likes
                .queryStarting(atValue: "Active")
                .observeSingleEvent(of: .value, with:{ (snapshot) in
                    self.activeCount = Int(snapshot.childrenCount)
                    self.tableView?.reloadData()
                })
        }
    }
    
    func deleteData(name: String) {
        
        let alert = UIAlertController(title: "Delete", message: "Confirm Delete", preferredStyle: .alert)
        let destroyAction = UIAlertAction(title: "Delete!", style: .destructive) { (action) in
            
            if ((self.defaults.string(forKey: "backendKey")) == "Parse") {
                
                let query = PFQuery(className:"Product")
                query.whereKey("objectId", equalTo: name)
                query.findObjectsInBackground(block: { objects, error in
                    if error == nil {
                        for object in objects! {
                            object.deleteInBackground()
                        }
                    }
                })
            } else {
                //firebase
                FirebaseRef.databaseRoot.child("Product").child(name).removeValue(completionBlock: { (error, ref) in
                    if error != nil {
                        print("Failed to delete message:", error!)
                        return
                    }
                })
            }
            let FeedbackGenerator = UINotificationFeedbackGenerator()
            FeedbackGenerator.notificationOccurred(.success)
            self.refreshData(self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.refreshData(self)
        }
        alert.addAction(cancelAction)
        alert.addAction(destroyAction)
        self.present(alert, animated: true) {
        }
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "prodDetailSegue" {
            let VC = (segue.destination as! UINavigationController).topViewController as! NewEditData
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
            VC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            VC.navigationItem.leftItemsSupplementBackButton = true
            
            VC.formController = "Product"
            if (isFormStat == true) {
                VC.formStatus = "New"
            } else {
                VC.formStatus = "Edit"
                
                if navigationItem.searchController?.isActive == true {
                    //search
                    let indexPath = resultsController.tableView!.indexPathForSelectedRow!.row
                    
                    VC.objectId = filteredTitles[indexPath].prodId
                    VC.frm11 = filteredTitles[indexPath].active
                    VC.frm12 = filteredTitles[indexPath].productNo
                    VC.frm13 = filteredTitles[indexPath].products
                    VC.frm14 = filteredTitles[indexPath].price
                    VC.imageUrl = filteredTitles[indexPath].imageUrl
                } else {
                    let indexPath = tableView!.indexPathForSelectedRow!.row
                    
                    if ((defaults.string(forKey: "backendKey")) == "Parse") {
                        VC.objectId = (_feedItems[indexPath] as AnyObject).value(forKey: "objectId") as? String
                        VC.frm11 = (_feedItems[indexPath] as AnyObject).value(forKey: "Active") as? String
                        VC.frm12 = (_feedItems[indexPath] as AnyObject).value(forKey: "ProductNo") as? String
                        VC.frm13 = (_feedItems[indexPath] as AnyObject).value(forKey: "Products") as? String
                        VC.frm14 = (_feedItems[indexPath] as AnyObject).value(forKey: "Price") as? Int
                        VC.image = self.selectedImage
                    } else {
                        //firebase
                        VC.objectId = prodlist[indexPath].prodId
                        VC.frm11 = prodlist[indexPath].active
                        VC.frm12 = prodlist[indexPath].productNo
                        VC.frm13 = prodlist[indexPath].products
                        VC.frm14 = prodlist[indexPath].price
                        VC.photo = prodlist[indexPath].photo
                        VC.imageUrl = prodlist[indexPath].imageUrl
                    }
                }
            }
        }
    }
    
    // MARK: - search
    func filterContentForSearchText(searchText: String, scope: String = "product") {
        
        filteredTitles = prodlist.filter { (prod: ProdModel) in
            let target: String
            switch(scope.lowercased()) {
            case "product":
                target = prod.products
            case "productNo":
                target = prod.productNo!
            case "active":
                target = prod.active
            default:
                target = prod.products
            }
            return target.lowercased().contains(searchText.lowercased())
        }
        DispatchQueue.main.async {
            self.resultsController.tableView.reloadData()
        }
    }
}
@available(iOS 13.0, *)
extension ProductVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.selectedImage = nil
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            
            let imageObject = _feedItems.object(at: indexPath.row) as? PFObject
            if let imageFile = imageObject!.object(forKey: "imageFile") as? PFFileObject {
                imageFile.getDataInBackground { imageData, error in
                    self.selectedImage = UIImage(data: imageData!)
                }
            }
        } else {
            //firebase
        }
        self.performSegue(withIdentifier: "prodDetailSegue", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                return _feedItems.count
            } else {
                return prodlist.count
            }
        }
        return filteredTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellIdentifier: String!
        
        if (tableView == self.tableView) {
            
            cellIdentifier = "Cell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TableViewCell
            
            cell.selectionStyle = .none
            cell.accessoryType = .disclosureIndicator
            cell.customImagelabel.text = "Prod"
            cell.customImagelabel.tag = indexPath.row
            cell.customImagelabel.backgroundColor = .systemTeal
            
            if UIDevice.current.userInterfaceIdiom == .pad  {
                cell.customtitleLabel.font = Font.celltitle22m
            }
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                cell.customtitleLabel.text = (_feedItems[indexPath.row] as AnyObject).value(forKey: "Products") as? String
            } else {
                //firebase
                cell.prodpost = prodlist[indexPath.row]
            }
            
            return cell
            
        } else {
            //search
            cellIdentifier = "UserFoundCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                //parse
                cell.textLabel!.text = (filteredTitles[indexPath.row] as AnyObject).value(forKey: "Products") as? String
                
            } else {
                
                let prod: ProdModel
                prod = filteredTitles[indexPath.row]
                cell.textLabel!.text = prod.products
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (tableView == self.tableView) {
            if UIDevice.current.userInterfaceIdiom == .phone  {
                return 85.0
            } else {
                return CGFloat.leastNormalMagnitude
            }
        }
        return 0
    }
}
@available(iOS 13.0, *)
extension ProductVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(section == 0) {
            if (tableView == self.tableView) {
                guard let header = tableView.dequeueReusableCell(withIdentifier: "Header") as? HeaderViewCell else { fatalError("Unexpected Index Path") }
                
                if ((defaults.string(forKey: "backendKey")) == "Parse") {
                    header.myLabel1.text = String(format: "%@%d", "Prod's\n", _feedItems.count)
                    header.myLabel2.text = String(format: "%@%d", "Active\n", _feedheadItems.count)
                    header.myLabel3.text = String(format: "%@%d", "Event\n", 0)
                } else {
                    header.myLabel1.text = String(format: "%@%d", "Prod's\n", prodlist.count)
                    header.myLabel2.text = String(format: "%@%d", "Active\n", activeCount ?? 0)
                    header.myLabel3.text = String(format: "%@%d", "Event\n", 0)
                }
                header.contentView.backgroundColor = .systemTeal //Color.Table.labelColor
                tableView.tableHeaderView = nil //header.header
                
                return header.contentView
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (tableView == self.tableView) {
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = .systemGroupedBackground
            } else {
                cell.backgroundColor = .secondarySystemGroupedBackground
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            var deleteStr : String?
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                deleteStr = ((self._feedItems.object(at: indexPath.row) as AnyObject).value(forKey: "objectId") as? String)!
                _feedItems.removeObject(at: indexPath.row)
            } else {
                //firebase
                deleteStr = prodlist[indexPath.row].productNo!
                self.prodlist.remove(at: indexPath.row)
            }
            self.deleteData(name: deleteStr!)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.refreshData(self)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // MARK: - Content Menu
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    private func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: AnyObject?) -> Bool {
        
        if (action == #selector(NSObject.copy)) {
            return true
        }
        return false
    }
    
    private func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: AnyObject?) {
        
        let cell = tableView.cellForRow(at: indexPath)
        pasteBoard.string = cell!.textLabel?.text
    }
}
@available(iOS 13.0, *)
extension ProductVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTitles.removeAll(keepingCapacity: false)
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
    }
}
