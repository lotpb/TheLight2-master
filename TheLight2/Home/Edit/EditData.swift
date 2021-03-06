//
//  EditController.swift
//  mySQLswift
//
//  Created by Peter Balsamo on 1/4/16.
//  Copyright © 2016 Peter Balsamo. All rights reserved.
//

import UIKit
import Parse
import FirebaseDatabase
import FirebaseAuth


@available(iOS 13.0, *)
final class EditData: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableView: UITableView?

    // MARK: NavigationController Hidden
    private var lastContentOffset: CGFloat = 0.0
    
    private var datePickerView = UIDatePicker(frame: .zero)
    private var pickerView : UIPickerView = UIPickerView()
    private var pickOption = ["Call", "Follow", "Looks Good", "Future", "Bought", "Dead", "Cancel", "Sold"]
    private var pickRate = ["A", "B", "C", "D", "F"]
    private var pickContract = ["A & S Home Improvement", "Islandwide Gutters", "Ashland Home Improvement", "John Kat Windows", "Jose Rosa", "Peter Balsamo"]
    
    private var date : UITextField!
    private var address : UITextField!
    private var city : UITextField!
    private var state : UITextField!
    private var zip : UITextField!
    private var aptDate : UITextField!
    private var phone : UITextField!
    private var salesman : UITextField!
    private var jobName : UITextField!
    private var adName : UITextField!
    private var amount : UITextField!
    private var email : UITextField!
    private var spouse : UITextField!
    private var callback : UITextField!
    private var start : UITextField! //cust
    private var complete : UITextField! //cust
    private var comment : UITextView!
    public var photo : UITextField!
    
    public var formController : String?
    public var status : String?
    public var objectId : String?
    public var custNo : String?
    public var leadNo : String?
    public var time : String?

    private var rate : String? //cust
    public var saleNo : String?
    public var jobNo : String?
    public var adNo : String?
    
    public var frm11 : String?
    public var frm12 : String?
    public var frm13 : String?
    public var frm14 : String?
    public var frm15 : String?
    public var frm16 : String?
    public var frm17 : String?
    public var frm18 : String?
    public var frm19 : String?
    public var frm20 : String?
    public var frm21 : String?
    public var frm22 : String?
    public var frm23 : String?
    public var frm24 : String?
    public var frm25 : String?
    public var frm26 : String?
    public var frm27 : String?
    public var frm28 : String?
    public var frm29 : String?
    public var frm30 : NSString?
    public var frm31 : String? //start
    public var frm32 : String? //completion
    public var profileImage : UIImage?
    
    private var defaults = UserDefaults.standard
    private var simpleStepper : UIStepper!
    private var lookupItem : String?
    private var pasteBoard = UIPasteboard.general

    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = imageView.width/2
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.systemBackground.cgColor
        imageView.layer.borderWidth = 2.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let editlabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Edit"
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()

    private let first: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        textField.layer.borderWidth = 0.7
        textField.backgroundColor = .systemBackground
        textField.font = Font.celltitle20l
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.keyboardAppearance = .dark
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let last: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        textField.layer.borderWidth = 0.7
        textField.backgroundColor = .systemBackground
        textField.font = Font.celltitle20l
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.keyboardAppearance = .dark
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let company: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        textField.layer.borderWidth = 0.7
        textField.backgroundColor = .systemBackground
        textField.font = Font.celltitle20l
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.keyboardAppearance = .dark
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let activeImage: CustomImageView = {
        let imageView = CustomImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        view?.backgroundColor = .secondarySystemGroupedBackground
        contentView?.backgroundColor = .clear
        mainView?.backgroundColor = .clear
        tableView?.backgroundColor = .clear
        passFieldData()
        setupTableView()
        setupNavigation()
        //setupForm()
        clearFormData()
        
        if (status == "New") {
            frm30 = "1"
        }
        
        if (status == "Edit") {
            loadData()
        }
        observeKeyboardNotifications() // Move Keyboard not working
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
        loadFormData()
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationController?.navigationBar.barTintColor = .black
        } else {
            navigationController?.navigationBar.barTintColor = ColorX.DGrayColor
        }
        
        tabBarController?.tabBar.isHidden = false
        // MARK: NavigationController Hidden
        NotificationCenter.default.addObserver(self, selector: #selector(EditData.hideBar(notification:)), name: NSNotification.Name("hide"), object: nil)
        
         //Fix Grey Bar on Bpttom Bar
        if UIDevice.current.userInterfaceIdiom == .phone {
            if let con = self.splitViewController {
                con.preferredDisplayMode = .allVisible //.primaryOverlay //problem
            }
        }
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
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(updateData))
        navigationItem.rightBarButtonItems = [saveButton]
        if UIDevice.current.userInterfaceIdiom == .pad  {
            navigationItem.title = String(format: "%@ %@", "TheLight Software - \(self.status!)", self.formController!)
        } else {
            navigationItem.title = String(format: "%@ %@", self.status!, self.formController!)
        }
    }
    
    private func setupTableView() {
        
        tableView!.delegate = self
        tableView!.dataSource = self
        tableView!.estimatedRowHeight = 44
        tableView!.rowHeight = UITableView.automaticDimension
        tableView!.backgroundColor = .clear
        tableView!.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        profileImageView.image = profileImage
        pickerView.delegate = self
        pickerView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: (#selector(EditData.updatePicker)), name: UITextField.textDidBeginEditingNotification, object: nil)

        self.first.autocapitalizationType = .words
        if (formController == "Vendor") {
            last.autocapitalizationType = .none
        } else {
            last.autocapitalizationType = .words
        }
        company.autocapitalizationType = .words

        mainView?.addSubview(profileImageView)
        mainView?.addSubview(editlabel)
        mainView?.addSubview(first)
        mainView?.addSubview(last)
        mainView?.addSubview(company)

        NSLayoutConstraint.activate([

            profileImageView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 9),
            profileImageView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 75),
            profileImageView.heightAnchor.constraint(equalToConstant: 75),

            editlabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 5),
            editlabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            editlabel.widthAnchor.constraint(equalToConstant: 36),
            editlabel.heightAnchor.constraint(equalToConstant: 20),

            first.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 0),
            first.leftAnchor.constraint( equalTo: profileImageView.rightAnchor, constant: 20),
            first.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            first.heightAnchor.constraint(equalToConstant: 30),

            last.topAnchor.constraint(equalTo: first.bottomAnchor, constant: 15),
            last.leftAnchor.constraint( equalTo: first.leftAnchor, constant: 0),
            last.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            last.heightAnchor.constraint(equalToConstant: 30),

            company.topAnchor.constraint(equalTo: last.bottomAnchor, constant: 15),
            company.leftAnchor.constraint( equalTo: first.leftAnchor, constant: 0),
            company.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            company.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    // MARK: - NavigationController Hidden
    @objc func hideBar(notification: NSNotification)  {
        let state = notification.object as! Bool
        navigationController?.setNavigationBarHidden(state, animated: true)
        UIView.animate(withDuration: 0.2, animations: {
            self.tabBarController?.hideTabBarAnimated(hide: state) //added
        }, completion: nil)
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
    
    // MARK: - Switch
    @objc func changeSwitch(_ sender: UISwitch) {
        
        if (sender.isOn) {
            self.frm30 = "1"
        } else {
            self.frm30 = "0"
        }
        self.tableView!.reloadData()
    }
    
    // MARK: - StepperValueChanged
    @objc func stepperValueDidChange(_ sender: UIStepper) {
        
        if (sender.tag == 13) {
            self.callback?.text = "\(Int(sender.value))"
        } else if (sender.tag == 10) {
            self.amount?.text = "\(Int(sender.value))"
        }
    }
    
    // MARK: - TextField
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - PickView
    @objc func updatePicker(){
        self.pickerView.reloadAllComponents()
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if callback.isFirstResponder {
            return pickOption.count
        } else if aptDate.isFirstResponder {
            return pickRate.count
        } else if company.isFirstResponder {
            return pickContract.count
        } else {
            return 0
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if callback.isFirstResponder {
            return "\(pickOption[row])"
        } else if aptDate.isFirstResponder {
            return "\(pickRate[row])"
        } else if company.isFirstResponder {
            return "\(pickContract[row])"
        }
        return nil
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if callback.isFirstResponder {
            self.callback.text = pickOption[row]
        } else if aptDate.isFirstResponder {
            self.aptDate.text = pickRate[row]
        } else if company.isFirstResponder {
            self.company.text = pickContract[row]
        }
    }
    
    // MARK: - Datepicker
    @objc func handleDatePicker(_ sender: UIDatePicker) {

        if date.isFirstResponder {
            self.date?.text = MasterViewController.dateFormatter.string(from: sender.date)
        } else if aptDate.isFirstResponder {
            self.aptDate?.text = MasterViewController.dateFormatter.string(from: sender.date)
        } else if start.isFirstResponder {
            self.start?.text = MasterViewController.dateFormatter.string(from: sender.date)
        } else if complete.isFirstResponder {
            self.complete?.text = MasterViewController.dateFormatter.string(from: sender.date)
        }
    }
    
    // MARK: - FieldData Header
    private func passFieldData() {
        /*
         if (self.formController == "Leads" || self.formController == "Customer") {
         self.last.borderStyle = UITextBorderStyle.roundedRect
         self.last.layer.borderColor = UIColor(red:151/255.0, green:193/255.0, blue:252/255.0, alpha: 1.0).cgColor
         self.last.layer.borderWidth = 2.0
         self.last.layer.cornerRadius = 7.0
         } */

        self.first.borderStyle = .roundedRect
        self.first.layer.borderColor = UIColor(red:151/255.0, green:193/255.0, blue:252/255.0, alpha: 1.0).cgColor
        self.first.layer.borderWidth = 2.0
        self.first.layer.cornerRadius = 7.0
        
        if self.frm11 != nil {
            let myString1 = self.frm11
            self.first.text = myString1!.removeWhiteSpace()
        } else {
            self.first.text = ""
        }
        
        if self.frm12 != nil {
            let myString2 = self.frm12
            self.last.text = myString2!.removeWhiteSpace()
        } else {
            self.last.text = ""
        }
        
        if self.frm13 != nil {
            let myString3 = self.frm13
            self.company.text = myString3!.removeWhiteSpace()
        } else {
            self.company.text = ""
        }
        
        if (formController == "Customer") {
            
            if (self.status == "New") {
                self.company.isHidden = true
            } else {
                self.company.placeholder = "Contractor..."
                self.company.inputView = self.pickerView
            }
        } else if (self.formController == "Vendor") {
            self.first.placeholder = "Company..."
            self.last.placeholder = "Webpage"
            self.company.placeholder = "Manager..."
            
        } else if (formController == "Employee") {
            self.first.placeholder = "First..."
            self.last.placeholder = "Last..."
            self.company.placeholder = "Subcontractor..."
            
        } else {
            self.company.isHidden = true
        }
        
    }
    
    // MARK: - Load Data
    private func loadData() {

        if (self.formController == "Leads") {
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                let query = PFQuery(className:"Advertising")
                query.whereKey("AdNo", equalTo: self.frm23!)
                query.cachePolicy = .cacheThenNetwork
                query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                    if error == nil {
                        self.adName!.text = object!.object(forKey: "Advertiser") as? String
                    }
                }
            } else {
                //firebase
                FirebaseRef.databaseRoot.child("Advertising")
                    .queryOrdered(byChild: "adNo")
                    .queryEqual(toValue: self.frm23!)
                    .observeSingleEvent(of: .value, with:{ (snapshot) in
                        for snap in snapshot.children {
                            let userSnap = snap as! DataSnapshot
                            let userDict = userSnap.value as! [String: Any]
                            self.adName!.text = userDict["advertiser"] as? String
                        }
                    })
            }
        } else if (self.formController == "Customer") {
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                let query = PFQuery(className:"Product")
                query.whereKey("ProductNo", equalTo: self.frm23!)
                query.cachePolicy = .cacheThenNetwork
                query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                    if error == nil {
                        self.adName!.text = object!.object(forKey: "Products") as? String
                    }
                }
            } else {
                //firebase
                FirebaseRef.databaseRoot.child("Product")
                    .queryOrdered(byChild: "productNo")
                    .queryEqual(toValue: self.frm23!)
                    .observeSingleEvent(of: .value, with:{ (snapshot) in
                        for snap in snapshot.children {
                            let userSnap = snap as! DataSnapshot
                            let userDict = userSnap.value as! [String: Any]
                            self.adName!.text = userDict["products"] as? String
                        }
                    })
            }
        }
        
        if (self.formController == "Leads" || self.formController == "Customer") {
            
            if ((defaults.string(forKey: "backendKey")) == "Parse") {
                
                let query1 = PFQuery(className:"Salesman")
                query1.whereKey("SalesNo", equalTo:self.frm21!)
                query1.cachePolicy = .cacheThenNetwork
                query1.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                    if error == nil {
                        self.salesman!.text = object!.object(forKey: "Salesman") as? String
                    }
                }
                
                let query = PFQuery(className:"Job")
                query.whereKey("JobNo", equalTo:self.frm22!)
                query.cachePolicy = .cacheThenNetwork
                query.getFirstObjectInBackground {(object: PFObject?, error: Error?) in
                    if error == nil {
                        self.jobName!.text = object!.object(forKey: "Description") as? String
                    }
                }
            } else {
                //firebase
                FirebaseRef.databaseRoot.child("Salesman")
                    .queryOrdered(byChild: "salesNo")
                    .queryEqual(toValue: self.frm21!)
                    .observeSingleEvent(of: .value, with:{ (snapshot) in
                        for snap in snapshot.children {
                            let userSnap = snap as! DataSnapshot
                            let userDict = userSnap.value as! [String: Any]
                            self.salesman!.text = userDict["salesman"] as? String
                        }
                    })
                
                FirebaseRef.databaseRoot.child("Job")
                    .queryOrdered(byChild: "jobNo")
                    .queryEqual(toValue: self.frm22!)
                    .observeSingleEvent(of: .value, with:{ (snapshot) in
                        for snap in snapshot.children {
                            let userSnap = snap as! DataSnapshot
                            let userDict = userSnap.value as! [String: Any]
                            self.jobName!.text = userDict["description"] as? String
                        }
                    })
            }
        }
    }
    
    // MARK: - Load Form Data
    private func loadFormData() {
        
        if (self.first.text == "") {
            self.first.text = defaults.string(forKey: "first")
        }
        if (self.last.text == "") {
            self.last.text = defaults.string(forKey: "last")
        }
        if (self.company.text == "") {
            self.company.text = defaults.string(forKey: "company")
        }
    }
    
    // MARK: Clear Form Data
    private func clearFormData() {
        
            self.defaults.removeObject(forKey: "first")
            self.defaults.removeObject(forKey: "last")
            self.defaults.removeObject(forKey: "company")
    }
    
    // MARK: Save Form Data
    private func saveFormData() {
        
        if (self.first.text != "") {
            self.defaults.set(self.first.text, forKey: "first")
        }
        if (self.last.text != "") {
            self.defaults.set(self.last.text, forKey: "last")
        }
        if (self.company.text != "") {
            self.defaults.set(self.company.text, forKey: "company")
        }
    }
    
    // MARK: - Move Keyboard
    private func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIApplication.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = .init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
            }, completion: nil)
    }
    
    @objc func keyboardShow() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.view.frame = .init(x: 0, y: -110, width: self.view.frame.width, height: self.view.frame.height)
            
            }, completion: nil)
    }
    
//------------------------------------------------
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "lookupDataSegue" {
            saveFormData()
            guard let controller = segue.destination as? LookupData else { return }
            controller.delegate = self
            controller.lookupItem = lookupItem
        }
    }
    
    // MARK: - Update Data
    @objc func updateData() {
        
        guard let textFirst = self.first.text else { return }
        guard let textLast = self.last.text else { return }
        guard let textComp = self.company.text else { return }

        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        if textFirst == "", textLast == "", textComp == "" {
            
            self.showAlert(title: "Oops!", message: "No text entered.")
            
        } else {
            
            MasterViewController.numberFormatter.numberStyle = .none

            MasterViewController.dateFormatter.dateFormat = "MMM dd yyyy"
            MasterViewController.dateFormatter.timeZone = .current
            
            let myActive : NSNumber = MasterViewController.numberFormatter.number(from: self.frm30! as String)!
            
            var Cust = self.custNo
            if Cust == nil { Cust = "" }
            let myCust = MasterViewController.numberFormatter.number(from: Cust! as String)
            
            var Lead = self.leadNo
            if Lead == nil { Lead = "" }
            let myLead = MasterViewController.numberFormatter.number(from: Lead! as String)
            
            var Amount = (self.amount.text)
            if Amount == nil { Amount = "" }
            let myAmount =  MasterViewController.numberFormatter.number(from: Amount!)
            
            var Zip = self.zip.text
            if Zip == nil { Zip = "" }
            let myZip = MasterViewController.numberFormatter.number(from: Zip!)
            
            var Sale = self.saleNo
            if Sale == nil { Sale = "" }
            let mySale = MasterViewController.numberFormatter.number(from: Sale!)
            
            var Job = self.jobNo
            if Job == nil { Job = "" }
            let myJob = MasterViewController.numberFormatter.number(from: Job! as String)
            
            var Ad = self.adNo
            if Ad == nil { Ad = "" }
            let myAd = MasterViewController.numberFormatter.number(from: Ad! as String)
            
            var Quan = self.callback.text
            if Quan == nil { Quan = "" }
            let myQuan = MasterViewController.numberFormatter.number(from: Quan! as String)

            if (self.formController == "Leads") {

                let item = self.aptDate.text
                let currentDate:NSDate = MasterViewController.dateFormatter.date(from: item!)! as NSDate
                let myTimeStamp = NSNumber(value: Int(currentDate.timeIntervalSince1970))
                
                if (self.status == "Edit") { //Edit Lead
                    
                    if ((defaults.string(forKey: "backendKey")) == "Parse") {
                        
                        let query = PFQuery(className:"Leads")
                        query.whereKey("objectId", equalTo:self.objectId!)
                        query.getFirstObjectInBackground {(updateLead: PFObject!, error: Error?) in
                            if error == nil {
                                updateLead!.setObject(myLead ?? NSNumber(value:-1), forKey:"LeadNo")
                                updateLead!.setObject(myActive, forKey:"Active")
                                updateLead!.setObject(self.date.text ?? NSNull(), forKey:"Date")
                                updateLead!.setObject(self.first.text ?? NSNull(), forKey:"First")
                                updateLead!.setObject(self.last.text ?? NSNull(), forKey:"LastName")
                                updateLead!.setObject(self.address.text ?? NSNull(), forKey:"Address")
                                updateLead!.setObject(self.city.text ?? NSNull(), forKey:"City")
                                updateLead!.setObject(self.state.text ?? NSNull(), forKey:"State")
                                updateLead!.setObject(myZip ?? NSNumber(value:-1), forKey:"Zip")
                                updateLead!.setObject(self.phone.text ?? NSNull(), forKey:"Phone")
                                updateLead!.setObject(self.aptDate.text ?? NSNull(), forKey:"AptDate")
                                updateLead!.setObject(self.email.text ?? NSNull(), forKey:"Email")
                                updateLead!.setObject(myAmount ?? NSNumber(value:-1), forKey:"Amount")
                                updateLead!.setObject(self.spouse.text ?? NSNull(), forKey:"Spouse")
                                updateLead!.setObject(self.callback.text ?? NSNull(), forKey:"CallBack")
                                updateLead!.setObject(mySale ?? NSNumber(value:-1), forKey:"SalesNo")
                                updateLead!.setObject(myJob ?? NSNumber(value:-1), forKey:"JobNo")
                                updateLead!.setObject(myAd ?? NSNumber(value:-1), forKey:"AdNo")
                                updateLead!.setObject(self.comment.text ?? NSNull(), forKey:"Coments")
                                //updateblog!.setObject(self.photo.text ?? NSNull(), forKey:"Photo")
                                updateLead!.saveEventually()
                                
                                self.showAlert(title: "Upload Complete", message: "Successfully updated the data")
                            } else {
                                self.showAlert(title: "Upload Failure", message: "Failure updating the data")
                            }
                        }
                    } else {
                        
                        //firebase Edit Lead
                        let userRef = FirebaseRef.databaseLeads.child(self.objectId!)
                        let values = ["first": self.first.text!,
                                      "lastname": self.last.text!,
                                      "address": self.address.text!,
                                      "city": self.city.text!,
                                      "state": self.state.text!,
                                      "phone": self.phone.text!,
                                      "aptdate": myTimeStamp,
                                      "email": self.email.text!,
                                      "spouse": self.spouse.text!,
                                      "callback": self.callback.text!,
                                      "comments": self.comment.text!,
                                      "active": myActive,
                                      "amount": myAmount!,
                                      "zip": myZip!,
                                      "salesNo": mySale!,
                                      "jobNo": myJob!,
                                      "adNo": myAd!,
                                      "photo": self.photo.text!,
                                      "lastUpdate": Date().timeIntervalSince1970,
                                      "leadId": self.objectId ?? "",
                                      "uid": uid
                                      //"leadNo": key,
                                      ] as [String: Any]
                        
                        userRef.updateChildValues(values) { (err, ref) in
                            if err != nil {
                                self.showAlert(title:"Upload Failure", message: "Failure updating the data")
                                return
                            }
                            self.showAlert(title: "update Complete", message: "Successfully updated the data")
                        }
                    }
                    
                } else { //Save Lead
                    
                    if ((defaults.string(forKey: "backendKey")) == "Parse") {
                        
                        let saveLead:PFObject = PFObject(className:"Leads")
                        saveLead.setObject(self.leadNo ?? NSNumber(value:-1), forKey:"LeadNo")
                        saveLead.setObject(myActive , forKey:"Active")
                        saveLead.setObject(self.date.text ?? NSNull(), forKey:"Date")
                        saveLead.setObject(self.first.text ?? NSNull(), forKey:"First")
                        saveLead.setObject(self.last.text ?? NSNull(), forKey:"LastName")
                        saveLead.setObject(self.address.text ?? NSNull(), forKey:"Address")
                        saveLead.setObject(self.city.text ?? NSNull(), forKey:"City")
                        saveLead.setObject(self.state.text ?? NSNull(), forKey:"State")
                        saveLead.setObject(myZip ?? NSNumber(value:-1), forKey:"Zip")
                        saveLead.setObject(self.phone.text ?? NSNull(), forKey:"Phone")
                        saveLead.setObject(self.aptDate.text ?? NSNull(), forKey:"AptDate")
                        saveLead.setObject(self.email.text ?? NSNull(), forKey:"Email")
                        saveLead.setObject(myAmount ?? NSNumber(value:0), forKey:"Amount")
                        saveLead.setObject(self.spouse.text ?? NSNull(), forKey:"Spouse")
                        saveLead.setObject(self.callback.text ?? NSNull(), forKey:"CallBack")
                        saveLead.setObject(mySale ?? NSNumber(value:-1), forKey:"SalesNo")
                        saveLead.setObject(myJob ?? NSNumber(value:-1), forKey:"JobNo")
                        saveLead.setObject(myAd ?? NSNumber(value:-1), forKey:"AdNo")
                        saveLead.setObject(self.comment.text ?? NSNull(), forKey:"Coments")
                        saveLead.setObject(self.photo ?? NSNull(), forKey:"Photo")
                        //PFACL.setDefault(PFACL(), withAccessForCurrentUser: true)
                        saveLead.saveInBackground { (success: Bool, error: Error?) in
                            if success == true {
                                self.showAlert(title: "Upload Complete", message: "Successfully updated the data")
                            } else {
                                self.showAlert(title: "Upload Failure", message: "Failure updating the data")
                            }
                        }
                    } else { //Save Lead
                        
                        //firebase
                        //guard let uid = Auth.auth().currentUser?.uid else {return}
                        let key = FirebaseRef.databaseLeads.childByAutoId().key
                        let values = ["first": self.first.text!,
                                      "lastname": self.last.text!,
                                      "address": self.address.text!,
                                      "city": self.city.text!,
                                      "state": self.state.text!,
                                      "phone": self.phone.text!,
                                      "email": self.email.text ?? "",
                                      "spouse": self.spouse.text ?? "",
                                      "callback": self.callback.text ?? "",
                                      "comments": self.comment.text!,
                                      "creationDate": Date().timeIntervalSince1970,
                                      "aptdate": myTimeStamp,
                                      "active": myActive,
                                      "amount": myAmount ?? NSNumber(value:-1) as! Int,
                                      "leadNo": key!,
                                      "zip": myZip ?? NSNumber(value:-1) as! Int,
                                      "salesNo": mySale ?? NSNumber(value:-1) as! Int,
                                      "jobNo": myJob ?? NSNumber(value:-1) as! Int,
                                      "adNo": myAd ?? NSNumber(value:-1) as! Int,
                                      "photo": self.photo.text ?? "",
                                      "leadId": key!,
                                      "uid": uid] as [String: Any]
                        
                        let childUpdates = ["/Leads/\(String(key!))": values]
                        FirebaseRef.databaseRoot.updateChildValues(childUpdates) { (err, ref) in
                            if err != nil {
                                self.showAlert(title: "Upload Failure", message: "Failure updating the data")
                                return
                            }
                            self.showAlert(title: "Upload Complete", message: "Successfully updated the data")
                        }
                    }
                }
            } else if (self.formController == "Customer") {

                guard let start = self.start.text else {return}
                let startDate:NSDate = MasterViewController.dateFormatter.date(from: start)! as NSDate
                let myStart = NSNumber(value: Int(startDate.timeIntervalSince1970))
                
                guard let completion = self.complete.text else {return}
                let completionDate:NSDate = MasterViewController.dateFormatter.date(from: completion)! as NSDate
                let myCompletion = NSNumber(value: Int(completionDate.timeIntervalSince1970))
                
                if (self.status == "Edit") { //Edit Customer
                    
                    if ((defaults.string(forKey: "backendKey")) == "Parse") {
                        
                        let query = PFQuery(className:"Customer")
                        query.whereKey("objectId", equalTo:self.objectId!)
                        query.getFirstObjectInBackground {(updateCust: PFObject?, error: Error?) in
                            if error == nil {
                                updateCust!.setObject(myCust ?? NSNumber(value:-1), forKey:"CustNo")
                                updateCust!.setObject(myLead ?? NSNumber(value:-1), forKey:"LeadNo")
                                updateCust!.setObject(myActive , forKey:"Active")
                                updateCust!.setObject(self.date.text ?? NSNull(), forKey:"Date")
                                updateCust!.setObject(self.first.text ?? NSNull(), forKey:"First")
                                updateCust!.setObject(self.last.text ?? NSNull(), forKey:"LastName")
                                updateCust!.setObject(self.address.text ?? NSNull(), forKey:"Address")
                                updateCust!.setObject(self.city.text ?? NSNull(), forKey:"City")
                                updateCust!.setObject(self.state.text ?? NSNull(), forKey:"State")
                                updateCust!.setObject(myZip ?? NSNumber(value:-1), forKey:"Zip")
                                updateCust!.setObject(self.phone.text ?? NSNull(), forKey:"Phone")
                                updateCust!.setObject(myQuan ?? NSNumber(value:-1), forKey:"Quan")
                                updateCust!.setObject(self.email.text ?? NSNull(), forKey:"Email")
                                updateCust!.setObject(myAmount ?? NSNumber(value:-1), forKey:"Amount")
                                updateCust!.setObject(self.spouse.text ?? NSNull(), forKey:"Spouse")
                                updateCust!.setObject(self.aptDate.text ?? NSNull(), forKey:"Rate")
                                updateCust!.setObject(mySale ?? NSNumber(value:-1), forKey:"SalesNo")
                                updateCust!.setObject(myJob ?? NSNumber(value:-1), forKey:"JobNo")
                                updateCust!.setObject(myAd ?? NSNumber(value:-1), forKey:"ProductNo")
                                updateCust!.setObject(self.start.text ?? NSNull(), forKey:"Start")
                                updateCust!.setObject(self.complete.text ?? NSNull(), forKey:"Completion")
                                updateCust!.setObject(self.comment.text ?? NSNull(), forKey:"Comments")
                                updateCust!.setObject(self.company.text ?? NSNull(), forKey:"Contractor")
                                updateCust!.setObject(self.photo ?? NSNull(), forKey:"Photo")
                                //updateCust!.setObject(self.photo1 ?? NSNull(), forKey:"Photo1")
                                //updateCust!.setObject(self.photo2 ?? NSNull(), forKey:"Photo2")
                                updateCust!.setObject(self.time ?? NSNull(), forKey:"Time")
                                updateCust!.saveEventually()
                                
                                self.showAlert(title: "Upload Complete", message: "Successfully updated the data")
                                
                            } else {
                                
                                self.showAlert(title: "Upload Failure", message: "Failure updating the data")
                            }
                        }
                    } else {
                        //firebase
                        let userRef = FirebaseRef.databaseCust.child(self.objectId!)
                        let values = ["first": self.first.text!,
                                      "lastname": self.last.text!,
                                      "address": self.address.text!,
                                      "city": self.city.text!,
                                      "state": self.state.text!,
                                      "phone": self.phone.text!,
                                      "contractor": self.company.text!,
                                      "email": self.email.text!,
                                      "spouse": self.spouse.text!,
                                      "comments": self.comment.text!,
                                      "rate": self.aptDate.text!,
                                      "active": myActive,
                                      "amount": myAmount!,
                                      "zip": myZip!,
                                      "quan": myQuan!,
                                      "salesNo": mySale!,
                                      "jobNo": myJob!,
                                      "adNo": myAd!,
                                      "photo": self.photo.text!,
                                      "start": myStart,
                                      "completion": myCompletion,
                                      "lastUpdate": Date().timeIntervalSince1970,
                                      //"creationDate": myDate,
                                      "uid": uid,
                                      "leadNo": self.leadNo ?? NSNumber(value:-1) as! Int,
                                      "custId": self.objectId ?? ""] as [String: Any]
                        
                        userRef.updateChildValues(values) { (err, ref) in
                            if err != nil {
                                self.showAlert(title:"Upload Failure", message: "Failure updating the data")
                                return
                            }
                            self.showAlert(title: "update Complete", message: "Successfully updated the data")
                        }
                    }
                } else { //Save Customer
                    
                    if ((defaults.string(forKey: "backendKey")) == "Parse") {
                        
                        let saveCust:PFObject = PFObject(className:"Customer")
                        saveCust.setObject(myCust ?? NSNumber(value:-1), forKey:"CustNo")
                        saveCust.setObject(myLead ?? NSNumber(value:-1), forKey:"LeadNo")
                        saveCust.setObject(myActive , forKey:"Active")
                        saveCust.setObject(self.date.text ?? NSNull(), forKey:"Date")
                        saveCust.setObject(self.first.text ?? NSNull(), forKey:"First")
                        saveCust.setObject(self.last.text ?? NSNull(), forKey:"LastName")
                        saveCust.setObject(self.company.text ?? NSNull(), forKey:"Contractor")
                        saveCust.setObject(self.address.text ?? NSNull(), forKey:"Address")
                        saveCust.setObject(self.city.text ?? NSNull(), forKey:"City")
                        saveCust.setObject(self.state.text ?? NSNull(), forKey:"State")
                        saveCust.setObject(myZip ?? NSNumber(value:-1), forKey:"Zip")
                        saveCust.setObject(self.phone.text ?? NSNull(), forKey:"Phone")
                        saveCust.setObject(self.aptDate.text ?? NSNull(), forKey:"Rate")
                        saveCust.setObject(mySale ?? NSNumber(value:-1), forKey:"SalesNo")
                        saveCust.setObject(myJob ?? NSNumber(value:-1), forKey:"JobNo")
                        saveCust.setObject(myAd ?? NSNumber(value:-1), forKey:"ProductNo")
                        saveCust.setObject(myAmount ?? NSNumber(value:0), forKey:"Amount")
                        saveCust.setObject(myQuan ?? NSNumber(value:-1), forKey:"Quan")
                        saveCust.setObject(self.email.text ?? NSNull(), forKey:"Email")
                        saveCust.setObject(self.spouse.text ?? NSNull(), forKey:"Spouse")
                        saveCust.setObject(self.callback.text ?? NSNull(), forKey:"CallBack")
                        saveCust.setObject(self.start.text ?? NSNull(), forKey:"Start")
                        saveCust.setObject(self.complete.text ?? NSNull(), forKey:"Completion")
                        saveCust.setObject(self.comment.text ?? NSNull(), forKey:"Comment")
                        saveCust.setObject(NSNull(), forKey:"Photo")
                        //PFACL.setDefault(PFACL(), withAccessForCurrentUser: true)
                        saveCust.saveInBackground { (success: Bool, error: Error?) in
                            if success == true {
                                self.showAlert(title: "Upload Complete", message: "Successfully updated the data")
                            } else {
                                self.showAlert(title: "Upload Failure", message: "Failure updating the data")
                            }
                        }
                    } else {
                        //firebase
                        //guard let uid = Auth.auth().currentUser?.uid else {return}
                        let key = FirebaseRef.databaseCust.childByAutoId().key
                        let values = ["first": self.first.text!,
                                      "lastname": self.last.text!,
                                      "address": self.address.text!,
                                      "city": self.city.text!,
                                      "state": self.state.text!,
                                      "phone": self.phone.text!,
                                      "contractor": self.company.text!,
                                      "email": self.email.text!,
                                      "spouse": self.spouse.text!,
                                      "comments": self.comment.text!,
                                      "rate": self.aptDate.text!,
                                      "custId": key!,
                                      "active": myActive,
                                      "amount": myAmount!,
                                      "custNo": key!,
                                      "leadNo": self.leadNo ?? NSNumber(value:-1) as! Int,
                                      "zip": myZip ?? NSNumber(value:-1) as! Int,
                                      "salesNo": mySale ?? NSNumber(value:-1) as! Int,
                                      "jobNo": myJob ?? NSNumber(value:-1) as! Int,
                                      "adNo": myAd ?? NSNumber(value:-1) as! Int,
                                      "quan": myQuan ?? NSNumber(value:-1) as! Int,
                                      "photo": self.photo.text ?? "",
                                      "creationDate": Date().timeIntervalSince1970,
                                      "start": Date().timeIntervalSince1970,
                                      "completion": Date().timeIntervalSince1970,
                                      "lastUpdate": Date().timeIntervalSince1970,
                                      "uid": uid,
                                      //"callback": self.callback.text!,
                                      ] as [String: Any]
                        
                        let childUpdates = ["/Customer/\(String(key!))": values]
                        FirebaseRef.databaseRoot.updateChildValues(childUpdates) { (err, ref) in
                            if err != nil {
                                self.showAlert(title:"Upload Failure", message: "Failure updating the data")
                                return
                            }
                            self.showAlert(title: "Upload Complete", message: "Successfully updated the data")
                        }
                    }
                }
            } else  if (self.formController == "Vendor") {
                
                var Active = (self.frm30)
                if Active == nil { Active = "0" }
                let myActive =  MasterViewController.numberFormatter.number(from: Active! as String)
                
                var Lead = (self.leadNo)
                if Lead == nil { Lead = "-1" }
                let myLead =  MasterViewController.numberFormatter.number(from: Lead! as String)
                
                if (self.status == "Edit") { //Edit Vendor
                    
                    if ((defaults.string(forKey: "backendKey")) == "Parse") {
                        
                        let query = PFQuery(className:"Vendors")
                        query.whereKey("objectId", equalTo:self.objectId!)
                        query.getFirstObjectInBackground {(updateVend: PFObject?, error: Error?) in
                            if error == nil {
                                updateVend!.setObject(myLead!, forKey:"VendorNo")
                                updateVend!.setObject(myActive!, forKey:"Active")
                                updateVend!.setObject(self.first.text ?? NSNull(), forKey:"Vendor")
                                updateVend!.setObject(self.address.text ?? NSNull(), forKey:"Address")
                                updateVend!.setObject(self.city.text ?? NSNull(), forKey:"City")
                                updateVend!.setObject(self.state.text ?? NSNull(), forKey:"State")
                                updateVend!.setObject(self.zip.text ?? NSNull(), forKey:"Zip")
                                updateVend!.setObject(self.phone.text ?? NSNull(), forKey:"Phone")
                                updateVend!.setObject(self.salesman.text ?? NSNull(), forKey:"Phone1")
                                updateVend!.setObject(self.jobName.text ?? NSNull(), forKey:"Phone2")
                                updateVend!.setObject(self.adName.text ?? NSNull(), forKey:"Phone3")
                                updateVend!.setObject(self.email.text ?? NSNull(), forKey:"Email")
                                updateVend!.setObject(self.last.text ?? NSNull(), forKey:"WebPage")
                                updateVend!.setObject(self.amount.text ?? NSNull(), forKey:"Department")
                                updateVend!.setObject(self.spouse.text ?? NSNull(), forKey:"Office")
                                updateVend!.setObject(self.company.text ?? NSNull(), forKey:"Manager")
                                updateVend!.setObject(self.date.text ?? NSNull(), forKey:"Profession")
                                updateVend!.setObject(self.aptDate.text ?? NSNull(), forKey:"Assistant")
                                updateVend!.setObject(self.comment.text ?? NSNull(), forKey:"Comments")
                                updateVend!.saveEventually()
                                
                                self.showAlert(title: "Upload Complete", message: "Successfully updated the data")
                                
                            } else {
                                
                                self.showAlert(title: "Upload Failure", message: "Failure updating the data")
                            }
                        }
                    } else {
                        //firebase
                        let userRef = FirebaseRef.databaseRoot.child("Vendor").child(self.objectId!)
                        let values = ["vendor": self.first.text!,
                                      "address": self.address.text!,
                                      "city": self.city.text!,
                                      "state": self.state.text!,
                                      "phone": self.phone.text!,
                                      "assistant": self.aptDate.text!,
                                      "email": self.email.text ?? "",
                                      "phone1": self.salesman.text ?? "",
                                      "phone2": self.jobName.text ?? "",
                                      "comments": self.comment.text!,
                                      "phone3": self.adName.text!,
                                      "active": myActive!,
                                      "department": self.amount.text!,
                                      "office": self.spouse.text!,
                                      "manager": self.company.text!,
                                      "profession": self.date.text!,
                                      "webpage": self.last.text!,
                                      "zip": myZip ?? NSNumber(value:-1) as! Int,
                                      "lastUpdate": Date().timeIntervalSince1970,
                                      "photo": self.photo.text ?? "",
                                      "uid": uid,
                                      "vendId": self.objectId ?? ""] as [String: Any]
                        
                        userRef.updateChildValues(values) { (err, ref) in
                            if err != nil {
                                self.showAlert(title:"Upload Failure", message: "Failure updating the data")
                                return
                            }
                            self.showAlert(title: "update Complete", message: "Successfully updated the data")
                        }
                    }
                } else { //Save Vendor
                    
                    if ((defaults.string(forKey: "backendKey")) == "Parse") {
                        
                        let saveVend:PFObject = PFObject(className:"Vendors")
                        saveVend.setObject(myLead!, forKey:"VendorNo")
                        saveVend.setObject(myActive!, forKey:"Active")
                        saveVend.setObject(self.first.text ?? NSNull(), forKey:"Vendor")
                        saveVend.setObject(self.address.text ?? NSNull(), forKey:"Address")
                        saveVend.setObject(self.city.text ?? NSNull(), forKey:"City")
                        saveVend.setObject(self.state.text ?? NSNull(), forKey:"State")
                        saveVend.setObject(self.zip.text ?? NSNumber(value:-1), forKey:"Zip")
                        saveVend.setObject(self.phone.text ?? NSNull(), forKey:"Phone")
                        saveVend.setObject(self.salesman.text ?? NSNull(), forKey:"Phone1")
                        saveVend.setObject(self.jobName.text ?? NSNull(), forKey:"Phone2")
                        saveVend.setObject(self.adName.text ?? NSNull(), forKey:"Phone3")
                        saveVend.setObject(self.email.text ?? NSNull(), forKey:"Email")
                        saveVend.setObject(self.last.text ?? NSNull(), forKey:"WebPage")
                        saveVend.setObject(self.amount.text ?? NSNull(), forKey:"Department")
                        saveVend.setObject(self.spouse.text ?? NSNull(), forKey:"Office")
                        saveVend.setObject(self.company.text ?? NSNull(), forKey:"Manager")
                        saveVend.setObject(self.date.text ?? NSNull(), forKey:"Profession")
                        saveVend.setObject(self.aptDate.text ?? NSNull(), forKey:"Assistant")
                        saveVend.setObject(self.comment.text ?? NSNull(), forKey:"Comments")
                        //PFACL.setDefault(PFACL(), withAccessForCurrentUser: true)
                        saveVend.saveInBackground { (success: Bool, error: Error?) in
                            if success == true {
                                
                                self.showAlert(title: "Upload Complete", message: "Successfully updated the data")
                            } else {
                                
                                self.showAlert(title: "Upload Failure", message: "Failure updating the data")
                            }
                        }
                    } else {
                        //firebase

                        //guard let uid = Auth.auth().currentUser?.uid else {return}
                        let key = FirebaseRef.databaseRoot.child("Vendor").childByAutoId().key
                        let values = ["vendor": self.first.text!,
                                      "address": self.address.text!,
                                      "city": self.city.text!,
                                      "state": self.state.text!,
                                      "phone": self.phone.text!,
                                      "assistant": self.aptDate.text!,
                                      "email": self.email.text ?? "",
                                      "phone1": self.salesman.text ?? "",
                                      "phone2": self.jobName.text ?? "",
                                      "comments": self.comment.text!,
                                      "phone3": self.adName.text!,
                                      "vendId": key!,
                                      "active": myActive!,
                                      "department": self.amount.text!,
                                      "office": self.spouse.text!,
                                      "manager": self.company.text!,
                                      "profession": self.date.text!,
                                      "webpage": self.last.text!,
                                      "photo": self.photo.text!,
                                      "zip": myZip ?? NSNumber(value:-1) as! Int,
                                      "vendNo": key!,
                                      "creationDate": Date().timeIntervalSince1970,
                                      "lastUpdate": Date().timeIntervalSince1970,
                                      "uid": uid] as [String: Any]
                        
                        let childUpdates = ["/Vendor/\(String(key!))": values]
                        FirebaseRef.databaseRoot.updateChildValues(childUpdates) { (err, ref) in
                            if err != nil {
                                self.showAlert(title:"Upload Failure", message: "Failure updating the data")
                                return
                            }
                            self.showAlert(title: "Upload Complete", message: "Successfully updated the data")
                        }
                    }
                }
            } else if (self.formController == "Employee") {
                
                var Active = (self.frm30)
                if Active == nil { Active = "0" }
                let myActive =  MasterViewController.numberFormatter.number(from: Active! as String)
                
                var Lead = (self.leadNo)
                if Lead == nil { Lead = "-1" }
                let myLead =  MasterViewController.numberFormatter.number(from: Lead!)
                
                if (self.status == "Edit") { //Edit Employee
                    
                    if ((defaults.string(forKey: "backendKey")) == "Parse") {
                        
                        let query = PFQuery(className:"Employee")
                        query.whereKey("objectId", equalTo:self.objectId!)
                        query.getFirstObjectInBackground {(updateEmploy: PFObject?, error: Error?) in
                            if error == nil {
                                updateEmploy!.setObject(myLead!, forKey:"EmployeeNo")
                                updateEmploy!.setObject(myActive!, forKey:"Active")
                                updateEmploy!.setObject(self.company.text ?? NSNull(), forKey:"Company")
                                updateEmploy!.setObject(self.address.text ?? NSNull(), forKey:"Address")
                                updateEmploy!.setObject(self.city.text ?? NSNull(), forKey:"City")
                                updateEmploy!.setObject(self.state.text ?? NSNull(), forKey:"State")
                                updateEmploy!.setObject(self.zip.text ?? NSNull(), forKey:"Zip")
                                updateEmploy!.setObject(self.phone.text ?? NSNull(), forKey:"HomePhone")
                                updateEmploy!.setObject(self.salesman.text ?? NSNull(), forKey:"WorkPhone")
                                updateEmploy!.setObject(self.jobName.text ?? NSNull(), forKey:"CellPhone")
                                updateEmploy!.setObject(self.adName.text ?? NSNull(), forKey:"SS")
                                updateEmploy!.setObject(self.email.text ?? NSNull(), forKey:"Email")
                                updateEmploy!.setObject(self.last.text ?? NSNull(), forKey:"Last")
                                updateEmploy!.setObject(self.amount.text ?? NSNull(), forKey:"Department")
                                updateEmploy!.setObject(self.spouse.text ?? NSNull(), forKey:"Country")
                                updateEmploy!.setObject(self.first.text ?? NSNull(), forKey:"First")
                                updateEmploy!.setObject(self.callback.text ?? NSNull(), forKey:"Manager")
                                updateEmploy!.setObject(self.date.text ?? NSNull(), forKey:"Title")
                                updateEmploy!.setObject(self.aptDate.text ?? NSNull(), forKey:"Middle")
                                updateEmploy!.setObject(self.comment.text ?? NSNull(), forKey:"Comments")
                                updateEmploy!.saveEventually()
                                
                                self.showAlert(title: "Upload Complete", message: "Successfully updated the data")
                                
                            } else {
                                
                                self.showAlert(title: "Upload Failure", message: "Failure updating the data")
                            }
                        }
                    } else {
                        //firebase
                        let userRef = FirebaseRef.databaseRoot.child("Employee").child(self.objectId!)
                        let values = ["lastname": self.last.text!,
                                      "address": self.address.text!,
                                      "city": self.city.text!,
                                      "state": self.state.text!,
                                      "homephone": self.phone.text!,
                                      "company": self.company.text!,
                                      "email": self.email.text ?? "",
                                      "workphone": self.salesman.text ?? "",
                                      "cellphone": self.jobName.text ?? "",
                                      "comments": self.comment.text!,
                                      "ss": self.adName.text!,
                                      "active": myActive!,
                                      "first": self.first.text!,
                                      "title": self.spouse.text!,
                                      "middle": self.aptDate.text!,
                                      "manager": self.callback.text!,
                                      "department": self.amount.text!,
                                      "country": self.date.text!,
                                      "zip": myZip ?? NSNumber(value:-1) as! Int,
                                      "photo": self.photo.text!,
                                      "lastUpdate": Date().timeIntervalSince1970,
                                      "uid": uid,
                                      "employeeId": self.objectId ?? ""] as [String: Any]
                        
                        userRef.updateChildValues(values) { (err, ref) in
                            if err != nil {
                                self.showAlert(title:"Upload Failure", message: "Failure updating the data")
                                return
                            }
                            self.showAlert(title: "update Complete", message: "Successfully updated the data")
                        }
                    }
                } else { //Save Employee
                    
                    if ((defaults.string(forKey: "backendKey")) == "Parse") {
                        
                        let saveEmploy:PFObject = PFObject(className:"Employee")
                        saveEmploy.setObject(NSNumber(value:-1), forKey:"EmployeeNo")
                        saveEmploy.setObject(NSNumber(value:1), forKey:"Active")
                        saveEmploy.setObject(self.company.text ?? NSNull(), forKey:"Company")
                        saveEmploy.setObject(self.address.text ?? NSNull(), forKey:"Address")
                        saveEmploy.setObject(self.city.text ?? NSNull(), forKey:"City")
                        saveEmploy.setObject(self.state.text ?? NSNull(), forKey:"State")
                        saveEmploy.setObject(self.zip.text ?? NSNull(), forKey:"Zip")
                        saveEmploy.setObject(self.phone.text ?? NSNull(), forKey:"HomePhone")
                        saveEmploy.setObject(self.salesman.text ?? NSNull(), forKey:"WorkPhone")
                        saveEmploy.setObject(self.jobName.text ?? NSNull(), forKey:"CellPhone")
                        saveEmploy.setObject(self.adName.text ?? NSNull(), forKey:"SS")
                        saveEmploy.setObject(self.date.text ?? NSNull(), forKey:"Country")
                        saveEmploy.setObject(self.email.text ?? NSNull(), forKey:"Email")
                        saveEmploy.setObject(self.last.text ?? NSNull(), forKey:"Last")
                        saveEmploy.setObject(self.amount.text ?? NSNull(), forKey:"Department")
                        saveEmploy.setObject(self.aptDate.text ?? NSNull(), forKey:"Middle")
                        saveEmploy.setObject(self.first.text ?? NSNull(), forKey:"First")
                        saveEmploy.setObject(self.callback.text ?? NSNull(), forKey:"Manager")
                        saveEmploy.setObject(self.spouse.text ?? NSNull(), forKey:"Title")
                        saveEmploy.setObject(self.comment.text ?? NSNull(), forKey:"Comments")
                        //PFACL.setDefault(PFACL(), withAccessForCurrentUser: true)
                        saveEmploy.saveInBackground { (success: Bool, error: Error?) in
                            if success == true {
                                
                                self.showAlert(title: "Upload Complete", message: "Successfully updated the data")
                                
                            } else {
                                
                                self.showAlert(title: "Upload Failure", message: "Failure updating the data")
                            }
                        }
                    } else {
                        //firebase
                        //guard let uid = Auth.auth().currentUser?.uid else {return}
                        let key = FirebaseRef.databaseRoot.child("Employee").childByAutoId().key
                        let values = ["lastname": self.last.text!,
                                      "address": self.address.text!,
                                      "city": self.city.text!,
                                      "state": self.state.text!,
                                      "homephone": self.phone.text!,
                                      "company": self.company.text!,
                                      "email": self.email.text ?? "",
                                      "workphone": self.salesman.text ?? "",
                                      "cellphone": self.jobName.text ?? "",
                                      "comments": self.comment.text!,
                                      "ss": self.adName.text!,
                                      "employeeId": key!,
                                      "active": myActive!,
                                      "first": self.first.text!,
                                      "title": self.spouse.text!,
                                      "middle": self.aptDate.text!,
                                      "manager": self.callback.text!,
                                      "department": self.amount.text!,
                                      "photo": self.photo.text!,
                                      "country": self.date.text!,
                                      "zip": myZip ?? NSNumber(value:-1) as! Int,
                                      "employeeNo": key!,
                                      "creationDate": Date().timeIntervalSince1970,
                                      "lastUpdate": Date().timeIntervalSince1970,
                                      "uid": uid] as [String: Any]
                        
                        let childUpdates = ["/Employee/\(String(key!))": values]
                        FirebaseRef.databaseRoot.updateChildValues(childUpdates) { (err, ref) in
                            if err != nil {
                                self.showAlert(title:"Upload Failure", message: "Failure updating the data")
                                return
                            }
                            self.showAlert(title: "Upload Complete", message: "Successfully updated the data")
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true)
                
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "homeId")
                self.show(vc, sender: self)
            }
            
            let FeedbackGenerator = UINotificationFeedbackGenerator()
            FeedbackGenerator.notificationOccurred(.success)
            
        }
    }
}
@available(iOS 13.0, *)
extension EditData: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.row == 3) {
            lookupItem = "City"
            self.performSegue(withIdentifier: "lookupDataSegue", sender: self)
        }
        if (indexPath.row == 7) {
            lookupItem = "Salesman"
            self.performSegue(withIdentifier: "lookupDataSegue", sender: self)
        }
        if (indexPath.row == 8) {
            lookupItem = "Job"
            self.performSegue(withIdentifier: "lookupDataSegue", sender: self)
        }
        if (indexPath.row == 9) {
            if (self.formController == "Customer") {
                lookupItem = "Product"
            } else {
                lookupItem = "Advertiser"
            }
            self.performSegue(withIdentifier: "lookupDataSegue", sender: self)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.formController == "Customer") {
            return 18
        } else {
            return 16
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 14 {
            return 100
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        let textframe: UITextField?
        let textviewframe: UITextView?
        let aptframe: UITextField? //zip field
        
        if ((defaults.string(forKey: "backendKey")) == "Parse") {
            MasterViewController.dateFormatter.dateFormat = "yyyy-MM-dd"
        } else {
            //firebase
            //EditData.dateFormatter.dateFormat = "MMM dd yy"
        }
        
        let dateString = MasterViewController.dateFormatter.string(from: (Date()) as Date)
        
        aptframe = UITextField(frame: .init(x: 220, y: 7, width: 80, height: 30))
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            
            textframe = UITextField(frame:.init(x: 118, y: 7, width: 250, height: 30))
            textviewframe = UITextView(frame:.init(x: 118, y: 7, width: 250, height: 85))
            activeImage.frame = .init(x: 118, y: 10, width: 18, height: 22)
            textframe!.font = Font.celltitle20l
            aptframe!.font = Font.celltitle20l
            textviewframe!.font = Font.celltitle20l
            
        } else {
            
            textframe = UITextField(frame: .init(x: 118, y: 7, width: 225, height: 30))
            textviewframe = UITextView(frame: .init(x: 118, y: 7, width: 240, height: 85))
            activeImage.frame = .init(x: 118, y: 10, width: 18, height: 22)
            textframe!.font = Font.celltitle20l
            aptframe!.font = Font.celltitle20l
            textviewframe!.font = Font.celltitle20l
        }
        
        textframe!.autocorrectionType = .no
        textframe!.clearButtonMode = .whileEditing
        textframe!.autocapitalizationType = .words
        textframe!.textColor = .label
        
        self.comment?.autocorrectionType = .default
        self.callback?.clearButtonMode = .never
        self.zip?.keyboardType = .decimalPad
        
        if (formController == "Leads" || formController == "Customer") {
            self.amount?.keyboardType = .decimalPad
        }
        if (formController == "Customer") {
            self.callback?.keyboardType = .decimalPad
        }
        if (formController == "Vendor") {
            self.last.keyboardType = .URL
            self.salesman?.keyboardType = .numbersAndPunctuation
            self.jobName?.keyboardType = .numbersAndPunctuation
            self.adName?.keyboardType = .numbersAndPunctuation
        }
        if (formController == "Employee") {
            self.salesman?.keyboardType = .numbersAndPunctuation
            self.jobName?.keyboardType = .numbersAndPunctuation
            self.adName?.keyboardType = .numbersAndPunctuation
        }
        self.email?.keyboardType = .emailAddress
        self.phone?.keyboardType = .numbersAndPunctuation
        self.email?.returnKeyType = UIReturnKeyType.next
        
        if (indexPath.row == 0) {
            
            let theSwitch = UISwitch(frame: .zero)
            self.activeImage.image = UIImage(systemName: "star.fill")
            
            if self.frm30 == "1" {
                theSwitch.isOn = true
                self.activeImage.tintColor = .systemYellow
                cell.textLabel!.text = "Active"
            } else {
                theSwitch.isOn = false
                self.activeImage.tintColor = .systemGray
                cell.textLabel!.text = "Inactive"
            }
            theSwitch.onTintColor = UIColor(red:0.0, green:122.0/255.0, blue:1.0, alpha: 1.0)
            theSwitch.tintColor = .lightGray
            theSwitch.addTarget(self, action: #selector(EditData.changeSwitch), for: .valueChanged)
            
            cell.addSubview(theSwitch)
            cell.accessoryView = theSwitch
            cell.contentView.addSubview(activeImage)
            
        } else if (indexPath.row == 1) {
            
            self.date = textframe
            self.date!.tag = 0
            
            if self.frm18 == nil {
                self.date!.text = ""
            } else {
                self.date!.text = self.frm18
            }
            
            if (self.formController == "Leads" || self.formController == "Customer") {
                if (self.status == "New") {
                    self.date?.text = dateString
                }
                self.date?.inputView = datePickerView
                datePickerView.datePickerMode = UIDatePicker.Mode.date
                datePickerView.addTarget(self, action: #selector(EditData.handleDatePicker), for: .valueChanged)
            }
            
            if (self.formController == "Vendor") {
                self.date?.placeholder = "Profession..."
                cell.textLabel!.text = "Profession"
                
            } else if (self.formController == "Employee") {
                self.date!.placeholder = "Title..."
                cell.textLabel!.text = "Title"
                
            } else {
                self.date?.placeholder = "Date..."
                cell.textLabel!.text = "Date"
            }
            
            cell.contentView.addSubview(self.date!)
            
        } else if (indexPath.row == 2) {
            
            self.address = textframe
            if self.frm14 == nil {
                self.address!.text = ""
            } else {
                self.address!.text = self.frm14
            }
            self.address!.placeholder = "Address..."
            cell.textLabel!.text = "Address"
            cell.contentView.addSubview(self.address!)
            
        } else if (indexPath.row == 3) {
            
            self.city = textframe
            if self.frm15 == nil {
                self.city!.text = ""
            } else {
                self.city!.text = self.frm15
            }
            cell.accessoryType = .disclosureIndicator
            self.city!.placeholder = "City..."
            cell.textLabel!.text = "City"
            cell.contentView.addSubview(self.city!)
            
        } else if (indexPath.row == 4) {
            
            self.state = textframe
            if self.frm16 == nil {
                self.state!.text = ""
            } else {
                self.state!.text = self.frm16
            }
            self.state!.placeholder = "State..."
            cell.textLabel!.text = "State"
            cell.contentView.addSubview(self.state!)
            
            self.zip = aptframe
            self.zip!.placeholder = "Zip..."
            if self.frm17 == nil {
                self.zip!.text = ""
            } else {
                self.zip!.text = self.frm17
            }
            
            cell.contentView.addSubview(self.zip!)
            
        } else if (indexPath.row == 5) {
            
            self.aptDate = textframe
            if self.frm19 == nil {
                self.aptDate!.text = ""
            } else {
                self.aptDate!.text = self.frm19
            }
            if (self.formController == "Customer") {
                self.aptDate!.placeholder = "Rate..."
                cell.textLabel!.text = "Rate"
                self.aptDate?.inputView = self.pickerView
                
            } else if (self.formController == "Vendor") {
                self.aptDate!.placeholder = "Assistant...."
                cell.textLabel!.text = "Assistant"
                
            } else if (self.formController == "Employee") {
                self.aptDate!.placeholder = "Middle..."
                cell.textLabel!.text = "Middle"
                
            } else { //leads
                if (self.status == "New") {
                    self.aptDate?.text = dateString
                }
                self.aptDate!.tag = 4
                self.aptDate!.placeholder = "Apt Date..."
                cell.textLabel!.text = "Apt Date"
                self.aptDate!.inputView = datePickerView
                datePickerView.datePickerMode = UIDatePicker.Mode.date
                datePickerView.addTarget(self, action: #selector(EditData.handleDatePicker), for: .valueChanged)
            }
            
            cell.contentView.addSubview(self.aptDate!)
            
        } else if (indexPath.row == 6) {
            
            self.phone = textframe
            self.phone!.placeholder = "Phone..."
            if (self.frm20 == nil) {
                self.phone!.text = defaults.string(forKey: "areacodeKey")
            } else {
                self.phone!.text = self.frm20
            }
            cell.textLabel!.text = "Phone"
            cell.contentView.addSubview(self.phone!)
            
        } else if (indexPath.row == 7) {
            
            self.salesman = textframe
            self.salesman!.adjustsFontSizeToFitWidth = true
            
            if self.frm21 == nil {
                self.salesman!.text = ""
            } else {
                self.salesman!.text = self.frm21
            }
            
            if (self.formController == "Vendor") {
                self.salesman!.placeholder = "Phone 1..."
                cell.textLabel!.text = "Phone 1"
                
            } else if (self.formController == "Employee") {
                self.salesman!.placeholder = "Work Phone..."
                cell.textLabel!.text = "Work Phone"
                
            } else {
                self.salesman!.placeholder = "Salesman..."
                cell.textLabel!.text = "Salesman"
                cell.accessoryType = .disclosureIndicator
            }
            
            cell.contentView.addSubview(self.salesman!)
            
        } else if (indexPath.row == 8) {
            
            self.jobName = textframe
            if self.frm22 == nil {
                self.jobName!.text = ""
            } else {
                self.jobName!.text = self.frm22
            }
            
            if (self.formController == "Vendor") {
                self.jobName!.placeholder = "Phone 2"
                cell.textLabel!.text = "Phone 2"
                
            } else if (self.formController == "Employee") {
                self.jobName!.placeholder = "Cell Phone"
                cell.textLabel!.text = "Cell Phone"
            } else {
                self.jobName!.placeholder = "Job..."
                cell.textLabel!.text = "Job"
                cell.accessoryType = .disclosureIndicator
            }
            
            cell.contentView.addSubview(self.jobName!)
            
        } else if (indexPath.row == 9) {
            self.adName = textframe
            //self.adName!.placeholder = "Advertiser"
            if self.frm23 == nil {
                self.adName!.text = ""
            } else {
                self.adName!.text = self.frm23
            }

            if (self.formController == "Vendor") {
                self.adName!.placeholder = "Phone 3..."
                cell.textLabel!.text = "phone 3"
                
            } else if (self.formController == "Employee") {
                self.adName!.placeholder = "Social Security..."
                cell.textLabel!.text = "Social Sec"
                
            } else if (self.formController == "Customer") {
                self.adName!.placeholder = "Product..."
                cell.textLabel!.text = "Product"
                
            } else {
                cell.textLabel!.text = "Advertiser"
            }

            if ((self.formController == "Leads") || (self.formController == "Customer")) {
                cell.accessoryType = .disclosureIndicator
            }

            cell.contentView.addSubview(self.adName!)
            
        } else if(indexPath.row == 10) {
            
            self.amount = textframe
            
            if ((self.formController == "Leads") || (self.formController == "Customer")) {
                if (self.status == "New") {
                    let simpleStepper = UIStepper(frame: .zero)
                    simpleStepper.tag = 10
                    simpleStepper.value = 0 //Double(self.amount.text!)!
                    simpleStepper.minimumValue = 0
                    simpleStepper.maximumValue = 10000
                    simpleStepper.stepValue = 100
                    simpleStepper.tintColor = .systemGray
                    cell.accessoryView = simpleStepper
                    simpleStepper.addTarget(self, action: #selector(EditData.stepperValueDidChange), for: .valueChanged)
                }
            }
            
            self.amount!.placeholder = "Amount..."
            if self.frm24 == nil {
                self.amount!.text = ""
            } else {
                self.amount!.text = self.frm24
            }
            cell.textLabel!.text = "Amount"
            
            if ((self.formController == "Vendor") || (self.formController == "Employee")) {
                self.amount!.placeholder = "Department..."
                cell.textLabel!.text = "Department"
            }
            
            cell.contentView.addSubview(self.amount!)
            
        } else if (indexPath.row == 11) {
            
            self.email = textframe
            self.email.autocapitalizationType = .none
            self.email!.placeholder = "Email..."
            if self.frm25 == nil {
                self.email!.text = ""
            } else {
                let myString = self.frm25
                self.email!.text = myString!.removeWhiteSpace() //extension
            }
            cell.textLabel!.text = "Email"
            cell.contentView.addSubview(self.email!)
            
        } else if(indexPath.row == 12) {
            self.spouse = textframe
            self.spouse!.placeholder = "Spouse..."
            
            if self.frm26 == nil {
                self.spouse!.text = ""
            } else {
                self.spouse!.text = self.frm26
            }
            
            if (formController == "Vendor") {
                self.spouse!.placeholder = "Office..."
                cell.textLabel!.text = "Office"
            } else if (formController == "Employee") {
                self.spouse!.placeholder = "Country..."
                cell.textLabel!.text = "Country"
            } else {
                cell.textLabel!.text = "Spouse"
            }
            
            cell.contentView.addSubview(self.spouse!)
            
        } else if (indexPath.row == 13) {
            self.callback = textframe
            
            if self.frm27 == nil {
                self.callback!.text = ""
            } else {
                self.callback!.text = self.frm27
            }
            
            if (self.formController == "Customer") {
                self.callback!.placeholder = "Quan..."
                cell.textLabel!.text = "# Windows"
                
                let simpleStepper = UIStepper(frame: .zero)
                simpleStepper.tag = 13
                if (self.status == "Edit") {
                    simpleStepper.value = Double(self.callback.text!)!
                } else {
                    simpleStepper.value = 0
                }
                
                simpleStepper.stepValue = 1
                simpleStepper.tintColor = .systemGray
                cell.accessoryView = simpleStepper
                simpleStepper.addTarget(self, action: #selector(EditData.stepperValueDidChange), for: .valueChanged)
            }
            else if (self.formController == "Vendor") {
                self.callback!.isHidden = true //Field
                self.callback!.placeholder = ""
                cell.textLabel!.text = ""
            }
            else if (self.formController == "Employee") {
                self.callback!.placeholder = "Manager..."
                cell.textLabel!.text = "Manager"
            }
            else {
                self.callback!.placeholder = "Call Back..."
                cell.textLabel!.text = "Call Back"
                self.callback?.inputView = self.pickerView
            }
            
            cell.contentView.addSubview(self.callback!)
            
        } else if (indexPath.row == 14) {
            self.comment = textviewframe
            if self.frm28 == nil {
                self.comment!.text = ""
            } else {
                self.comment!.text = self.frm28
            }
            cell.textLabel!.text = "Comments"
            cell.contentView.addSubview(self.comment!)
            
        } else if(indexPath.row == 15) {
            if (self.formController == "Customer") {
                self.start = textframe
                self.start!.placeholder = "Start Date..."
                if self.frm31 == nil {
                    self.start!.text = ""
                } else {
                    self.start!.text = self.frm31
                }
                self.start!.inputView = datePickerView
                datePickerView.addTarget(self, action: #selector(EditData.handleDatePicker), for: .valueChanged)
                cell.textLabel!.text = "Start Date"
                cell.contentView.addSubview(self.start!)
            } else {
                self.photo = textframe
                self.photo!.placeholder = "Photo..."
                if self.frm29 == nil {
                    self.photo!.text = ""
                } else {
                    self.photo!.text = self.frm29
                }
                cell.textLabel!.text = "Photo"
                cell.contentView.addSubview(self.photo!)
            }
            
        } else if(indexPath.row == 16) {
            self.complete = textframe
            self.complete!.placeholder = "Completion Date..."
            
            if self.frm32 == nil {
                self.complete!.text = ""
            } else {
                self.complete!.text = self.frm32
            }
            self.complete!.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(EditData.handleDatePicker), for: .valueChanged)
            cell.textLabel!.text = "End Date"
            cell.contentView.addSubview(self.complete!)
        } else if(indexPath.row == 17) {
            self.photo = textframe
            self.photo!.placeholder = "Photo..."
            if self.frm29 == nil {
                self.photo!.text = ""
            } else {
                self.photo!.text = self.frm29
            }
            cell.textLabel!.text = "Photo"
            cell.contentView.addSubview(self.photo!)
        }

        
        return cell
    }
}
@available(iOS 13.0, *)
extension EditData: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
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
extension EditData: LookupDataDelegate {
    func cityFromController(_ passedData: String) {
        self.city.text = passedData as String
    }
    func stateFromController(_ passedData: String) {
        self.state.text = passedData as String
    }
    func zipFromController(_ passedData: String) {
        self.zip.text = passedData as String
    }
    func salesFromController(_ passedData: String) {
        self.saleNo = passedData as String
    }
    func salesNameFromController(_ passedData: String) {
        self.salesman.text = passedData as String
    }
    func jobFromController(_ passedData: String) {
        self.jobNo = passedData as String
    }
    func jobNameFromController(_ passedData: String) {
        self.jobName.text = passedData as String
    }
    func productFromController(_ passedData: String) {
        self.adNo = passedData as String
    }
    func productNameFromController(_ passedData: String) {
        self.adName.text = passedData as String
    }
}
