//
//  MasterViewController.swift
//  Mandatory2
//
//  Created by Magnus Holm Svendsen on 01/05/2018.
//  Copyright © 2018 Magnus Holm Svendsen. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    
    @IBOutlet var popOver: UIView!
    
    var jokesArray = [Joke]()
    var jokesDictionary = [String: String]()
    
    var attemptCount = 0
    let maxAttempts = 10
    
    let saveData = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(getJoke(_:)))
        navigationItem.rightBarButtonItem = addButton
        addButton.title = "Add"
        addButton.tintColor = .yellow
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        self.popOver.layer.cornerRadius = 20
        self.popOver.layer.borderWidth = 0.8
        self.popOver.layer.borderColor = UIColor.black.cgColor
        
        jokesDictionary = saveData.object(forKey: "JokesDictionary") as? [String: String] ?? [String: String]()
        for (title, content) in jokesDictionary {
            let joke = Joke()
            joke.title = title
            joke.content = content
            jokesArray.append(joke)
        }
        
        setEditing(false, animated: true)
        
        if (jokesArray.count == 0) {
            displayPopOver(show: true)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.editButtonItem.tintColor = .yellow
        
        if (editing) {
            self.editButtonItem.title = NSLocalizedString("Done", comment: "Done")

        } else {
            self.editButtonItem.title = NSLocalizedString("Remove", comment: "Remove")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }


    @objc
    func getJoke(_ sender: Any) {
        if let url = URL(string: "https://08ad1pao69.execute-api.us-east-1.amazonaws.com/dev/random_joke") {
            do {
                let text = try String(contentsOf: url)
                let titlePattern = "(?<=\"setup\":\")(.*)(?=\",\"punchline)"
                let contentPattern = "(?<=punchline\":\")(.*)(?=\")"
                let titleArray = matches(for: titlePattern, in: text)
                let contentArray = matches(for: contentPattern, in: text)
                let title = titleArray[0].replacingOccurrences(of: "\n", with: "")
                let content = contentArray[0].replacingOccurrences(of: "\n", with: "")
   
                let newJoke = Joke()
                newJoke.title = title
                newJoke.content = content
                
                for (Joke: joke) in jokesArray {
                    if (joke.title == title) {
                        if (attemptCount < maxAttempts) {
                            attemptCount += 1
                            getJoke(NSObject.self)
                            return
                        } else {
                            attemptCount = 0
                            let alert = UIAlertController(title: "No more jokes!", message: "There are no more unique jokes at this time. Please try again later.", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "OK, got it", style: .default, handler: nil))
                            
                            self.present(alert, animated: true)
                            return
                        }
                    }
                }
                
                jokesArray.insert(newJoke, at: 0)
                jokesDictionary[title] = content
                saveData.set(jokesDictionary, forKey: "JokesDictionary")
                let indexPath = IndexPath(row: 0, section: 0)
                tableView.insertRows(at: [indexPath], with: .automatic)
            } catch {
                print("problem loading content")
            }
        } else {
            print("bad url")
        }
    }
    
    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let joke = jokesArray[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = joke
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    func displayPopOver(show: Bool) {
        if (show) {
            self.view.addSubview(popOver)
            popOver.center = CGPoint(x: self.view.center.x, y: 70)
            self.tableView.alwaysBounceVertical = false
            self.view.bringSubview(toFront: popOver)
        } else {
            self.popOver.removeFromSuperview()
            self.tableView.alwaysBounceVertical = true
        }
    }
    
    @IBAction func popOverCloseBtn(_ sender: Any) {
        displayPopOver(show: false)
    }
    

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jokesArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let joke = jokesArray[indexPath.row]
        cell.textLabel!.text = joke.title
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            jokesDictionary.removeValue(forKey: jokesArray[indexPath.row].title)
            jokesArray.remove(at: indexPath.row)
            saveData.set(jokesDictionary, forKey: "JokesDictionary")
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

