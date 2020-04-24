//
//  ViewController.swift
//  SimpleTranslate
//
//  Created by Artur Antonov on 04/12/2019.
//  Copyright © 2019 Artur. All rights reserved.
//

import UIKit
import Foundation
import Combine

class ViewController: UIViewController {

    private var textInputView: UITextView!
    private var textOutputView: UITextView!
    @Published var requestString: String?
    var subscriber: AnyCancellable?
    override func viewDidLoad() {
        super.viewDidLoad()
        subscriber = AnyCancellable($requestString
            .removeDuplicates()
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink(){[unowned self] sendString in
                self.sendRequest(requestString: sendString)
        })
    
        view.backgroundColor = UIColor(red: 1, green: 0.88, blue: 0.45, alpha: 1)
        let font = UIFont.systemFont(ofSize: 20)
        textInputView = UITextView(frame:
            CGRect(x: 8, y: 44, width: view.bounds.width - 16, height: 100)
        )
        textInputView.font = font
        textInputView.delegate = self
        view.addSubview(textInputView)
        let separator = UIView(frame:
            CGRect(x: 6, y: 148, width: view.bounds.width - 12, height: 2)
        )
        separator.backgroundColor = .gray
        view.addSubview(separator)
        textOutputView = UITextView(frame:
            CGRect(x: 8, y: 154, width: view.bounds.width - 16, height: 100)
        )
        textOutputView.font = font
        textOutputView.isEditable = false
        view.addSubview(textOutputView)
    }
    func sendRequest(requestString: String?){
        if let text = requestString{
            let apiKey = ""
            let url = URL(
              string: "https://translate.yandex.net/api/v1.5/tr.json/translate?key=\(apiKey)&text=\(text)&lang=en-ru"
            )!
            URLSession.shared.dataTask(with: url) { (data, response, error) in
              guard let data = data else {
                return
              }
              let dictionary = try! JSONSerialization.jsonObject(
                with: data,
                options: []
              ) as! [String: Any]
              let translation = dictionary["text"] as! [String]
              DispatchQueue.main.async {
                self.textOutputView.text = translation.first!
              }
            }.resume()
        }
    }
}

extension ViewController: UITextViewDelegate {

    
  func textViewDidChange(_ textView: UITextView) {
    guard !textView.text.isEmpty else {
      textOutputView.text = ""
      return
    }
    let text = textView.text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    self.requestString = text
}
}
