//
//  ViewController.swift
//  MyContactsPhotos
//
//  Created by Charles Konkol on 11/30/17.
//  Copyright © 2017 RockValleyCollege. All rights reserved.
//
//0) Add import for CoreData
import CoreData
import UIKit

class ViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    //Image

    var newImageData:NSData?
    var myImageFromData:NSData?
    @IBOutlet weak var fullname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var photos: UIImageView!
    @IBOutlet weak var btnSelect: UIButton!
    
    //**Begin Copy**
    //3) Add ManagedObject Data Context
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //**End Copy**
    
    
    //**Begin Copy**
    //4) Add variable contactdb (used from UITableView
    var contactdb:NSManagedObject!
    //**End Copy**
    
    @IBAction func btnEdit(_ sender: UIButton) {
        //0) Add import for CoreDataimport CoreData
        
 //0a Edit contact
        fullname.isEnabled = true
        email.isEnabled = true
        phone.isEnabled = true
        btnSave.isHidden = false
        btnEdit.isHidden = true
        btnSelect.isHidden=false
        fullname.becomeFirstResponder()
    }
    
    @IBAction func btnCall(_ sender: UIButton) {
        //**Begin Copy**
        
        //0b Call Number
        
        //if number not null
        if (phone.text !=  ""){
            let formatedNumber = phone.text!.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
            print("calling \(formatedNumber)")
            let phoneUrl = "tel://\(formatedNumber)"
            let url:URL = URL(string: phoneUrl)!
            UIApplication.shared.open(url)
        }
        //**End Copy**
    }
    
    @IBAction func btnSelect(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
            print("Take Photo")
            let imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            //imag.mediaTypes = [kUTTypeImage];
            imag.allowsEditing = false
            self.present(imag, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnSave(_ sender: AnyObject) {
        //**Begin Copy**
        //1 Add Save Logic
        
        
        if (contactdb != nil)
        {
            
            contactdb.setValue(fullname.text, forKey: "fullname")
            contactdb.setValue(email.text, forKey: "email")
            contactdb.setValue(phone.text, forKey: "phone")
            newImageData = UIImageJPEGRepresentation(photos.image!, 1) as NSData?
            contactdb.setValue(newImageData, forKey: "photos")
            let myData: NSData? = contactdb.value(forKey: "photos") as? NSData
            photos.image = UIImage(data: myData! as Data)
        }
        else
        {
            let entityDescription =
                NSEntityDescription.entity(forEntityName: "Contact",in: managedObjectContext)
            
            let contact = Contact(entity: entityDescription!,
                                  insertInto: managedObjectContext)
            
            contact.fullname = fullname.text!
            contact.email = email.text!
            contact.phone = phone.text!
            contact.photos = UIImageJPEGRepresentation(photos.image!, 1)
        }
        var error: NSError?
        do {
            try managedObjectContext.save()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let err = error {
            //if error occurs
            status.text = err.localizedFailureReason
        } else {
            self.dismiss(animated: false, completion: nil)
            
        }
        //**End Copy**
    }
    
    
    @IBAction func btnBack(_ sender: UIBarButtonItem) {
        //**Begin Copy**
        //2) Dismiss ViewController
        self.dismiss(animated: false, completion: nil)
        //**End Copy**
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //**Begin Copy**
        //5 Add logic to load db. If contactdb has content that means a row was tapped on UiTableView
        
        
        if (contactdb != nil)
        {
            fullname.text = contactdb.value(forKey: "fullname") as? String
            email.text = contactdb.value(forKey: "email") as? String
            phone.text = contactdb.value(forKey: "phone") as? String
            btnSave.setTitle("Update", for: UIControlState())
            let myData: NSData? = contactdb.value(forKey: "photos") as? NSData
            photos.image = UIImage(data: myData! as Data)
            btnCall.isHidden = false
            btnEdit.isHidden = false
            fullname.isEnabled = false
            email.isEnabled = false
            phone.isEnabled = false
            btnSave.isHidden = true
           btnSelect.isHidden=true
        }else{
            btnCall.isHidden = true
            btnEdit.isHidden = true
            fullname.isEnabled = true
            email.isEnabled = true
            phone.isEnabled = true
            status.isHidden = true
            btnSelect.isHidden=false
        }
        fullname.becomeFirstResponder()
        // Do any additional setup after loading the view.
        //Looks for single or multiple taps
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(ViewController.DismissKeyboard))
        //Adds tap gesture to view
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //**Begin Copy**
    //6 Add to hide keyboard
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches , with:event)
        if (touches.first as UITouch!) != nil {
            DismissKeyboard()
        }
    }
    //**End Copy**
    
    
    //**Begin Copy**
    //7 Add to hide keyboard
    
    @objc func DismissKeyboard(){
        //forces resign first responder and hides keyboard
        fullname.endEditing(true)
        email.endEditing(true)
        phone.endEditing(true)
        
    }
    //**End Copy**
    
    //**Begin Copy**
    
    //8 Add to hide keyboard
    
    func textFieldShouldReturn(_ textField: UITextField!) -> Bool     {
        textField.resignFirstResponder()
        return true;
    }
    //**End Copy**
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photos.contentMode = .scaleAspectFit
            photos.image = pickedImage
            newImageData = UIImageJPEGRepresentation(pickedImage, 1) as NSData?
        }
        
        self.dismiss(animated: true, completion: nil)
        
        
    }

}

