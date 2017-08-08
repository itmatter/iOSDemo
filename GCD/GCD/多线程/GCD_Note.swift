//
//  GCD_Note.swift
//  Work
//
//  Created by 李礼光 on 2017/7/19.
//  Copyright © 2017年 LG. All rights reserved.
//

import UIKit

class GCD_Note: UIViewController  {
    
    var tableView : UITableView!
    var noteTF : UILabel!
    
    let notes : [String] = [
            "同步,异步",
            "队列"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNote()
        tableView = UITableView(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64), style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "noteCell")
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        
        noteTF = UILabel(frame:  CGRect(x: 10, y: 74, width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height - 84))
        noteTF.textAlignment = .left
        noteTF.isUserInteractionEnabled = true
        noteTF.backgroundColor = UIColor.black
        noteTF.textColor = UIColor.white
        noteTF.numberOfLines = 0
        
        let button = UIButton(type: .custom)
        button.frame = noteTF.bounds
        button.addTarget(self, action: #selector(self.dismissFromSuperview), for: .touchUpInside)
        button.backgroundColor = UIColor.clear
        noteTF.addSubview(button)
        
    }
    
    @objc func dismissFromSuperview() {
        print("dismiss")
        self.noteTF.removeFromSuperview()
    }
    
    
}

extension GCD_Note : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell")
        cell?.textLabel?.text = notes[indexPath.row]
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UIView.animate(withDuration: 0.8) {
            let s = self.notes[indexPath.row]
            self.noteTF.text = self.getNote(noteKey: s)
            self.view.addSubview(self.noteTF)
        }
        
    }
}

extension GCD_Note {
    func setNote()  {
        var key = notes[0]
        var value = "同步和异步（影响线程数）\n\n同步：只能在当前线程中执行任务，不具备开启新线程的能力;在当前线程执行并且在所在队列中马上执行（重要）\n\n异步：可以在新的线程中执行任务，具备开启新线程的能力（具备不代表一定开启新的线程），不要求马上执行\n\n\n简单粗暴理解\n就是要不要开子线程,如果要开那么就是异步,如果不开,那么就是同步  "
        UserDefaults.standard.set(value, forKey: key)
        
        
        key = notes[1]
        value = "并发队列（Concurrent Dispatch Queue）\n#自动开启多个线程同时执行任务\n#并发功能只有在异步函数下才有效\n\n 串行队列（Serial Dispatch Queue）\n#一个任务执行完毕后，再执行下一个任务 \n\n主队列（跟主线程相关联的队列）\n\n#主队列是GCD自带的一种特殊的串行队列\n#在主队列中的任务，都会在主线程中执行\n\n#主线程主队列执行的任务中存在同步函数+主队列任务，会导致死锁（因为主队列中的当前任务并没有完成，它的下一个任务是新增的同步函数+主队列任务，并且要求所在线程立即执行所在队列（所在队列不是当前队列），系统无法在队列中的当前任务没处理完成前切换任务，导致死锁）\n"
        UserDefaults.standard.set(value, forKey: key)
        
    }
    
    func getNote(noteKey : String) -> String  {
        guard let value = UserDefaults.standard.value(forKey: noteKey) else { return "nil" }
        return  value as! String
    }
    
}



