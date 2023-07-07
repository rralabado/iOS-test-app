import UIKit
import CoreServices
import MessageUI

class ViewController: UIViewController, UIDocumentPickerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a button
        let selectFolderButton = UIButton(type: .system)
        selectFolderButton.setTitle("Select Folder", for: .normal)
        selectFolderButton.addTarget(self, action: #selector(selectFolderTapped), for: .touchUpInside)
        view.addSubview(selectFolderButton)
        
        // Add constraints to center the button in the view
        selectFolderButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectFolderButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectFolderButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc func selectFolderTapped() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeFolder)], in: .open)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedUrl = urls.first else { return }
        
        let isAccessGranted = selectedUrl.startAccessingSecurityScopedResource()
        defer {
            selectedUrl.stopAccessingSecurityScopedResource()
        }
        
        if isAccessGranted {
            print("Access granted to folder: \(selectedUrl.path)")
            
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: selectedUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                
                print(contents.count)
                print(contents.first?.path)
                
                // Probbaly gonna want to turn this into a list of paths so we can add more than one file
                sendEmail(subject: "this is a subject", body: "this is a body", recipientEmail: "rralabado@launchcg.com", attachmentFilePath: contents.first?.path, viewController: self)
                
                // You can display the contents in a table view or in any other way you want
            } catch {
                print("Error accessing folder contents: \(error.localizedDescription)")
            }
        } else {
            print("Permission denied for folder: \(selectedUrl.path)")
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    // Handle the cancellation here
    // This is called if the folder selection is canceled. Not sure how, it might be an overriden function(?) It has to have this exact name to work.
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled")
        controller.dismiss(animated: true, completion: nil)
    }
    
    func sendEmail(subject: String, body: String, recipientEmail: String, attachmentFilePath: String?, viewController: UIViewController) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.setSubject(subject)
            mailComposer.setMessageBody(body, isHTML: false)
            mailComposer.setToRecipients([recipientEmail])
            
            if let filePath = attachmentFilePath,
               let fileData = FileManager.default.contents(atPath: filePath) {
                let fileName = (filePath as NSString).lastPathComponent
                mailComposer.addAttachmentData(fileData, mimeType: "application/octet-stream", fileName: fileName)
            }
            
            viewController.present(mailComposer, animated: true, completion: nil)
        } else {
            // Device is not configured to send emails
            print("Error: Email cannot be sent from this device.")
            // You can display an alert or provide feedback to the user
        }
    }
}
