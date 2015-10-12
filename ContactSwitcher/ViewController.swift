//
//  ViewController.swift
//  ContactSwitcher
//
//  Created by Josh on 10/10/15.
//  Copyright © 2015 Josh. All rights reserved.
//

import UIKit

import Contacts

class ViewController: UIViewController {
    
    var contactStore: CNContactStore!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactStore = CNContactStore()
    }

    @IBAction func switchPressed(sender: AnyObject) {
        contactStore.requestAccessForEntityType(.Contacts) { (access, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (access) {
                    self.switchContacts()
                } else {
                    print("no access")
                }
            })
        }
    }
    
    private func switchContacts() {
        var contacts = [CNMutableContact]()
        
        do {
            let request = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey, CNContactFamilyNameKey])
            try contactStore.enumerateContactsWithFetchRequest(request) { (contact, stop) -> Void in
                contacts.append(contact.mutableCopy() as! CNMutableContact)
            }
        } catch {
            print(error)
            
            let alert = UIAlertController(title: "Error", message: "Error enumerating contacts", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        print("before: \(contacts)")
        
        let saveRequest = CNSaveRequest()
        for contact in contacts {
            let givenName = contact.givenName
            contact.givenName = contact.familyName
            contact.familyName = givenName
            saveRequest.updateContact(contact)
        }
        
        print("\n\n")
        
        print("after: \(contacts)")
        
        do {
            try contactStore.executeSaveRequest(saveRequest)
            print("\n\nFINISHED!!\n\n")
        } catch {
            print(error)
            
            let alert = UIAlertController(title: "Error", message: "Error saving contacts", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}

