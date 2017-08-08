//
//  GCD_Demo.swift
//  Work
//
//  Created by 李礼光 on 2017/7/18.
//  Copyright © 2017年 LG. All rights reserved.
//

import UIKit

class GCD_Demo: UIViewController {
    
    @IBOutlet var resultTF: UITextView!
    
    var downloadCount : Int = 0
    let imageView = UIImageView(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gcdDes()
    }
    
    @IBAction func async_Concurrent(_ sender: Any) {
        //注意 :
        // 1) .在使用的时候, 我们一般不去创建并行队列, 而是使用系统为我们提供的全局的并行队列:
        // 2) .默认方法有五个参数,使用默认值就可以了
        let q = DispatchQueue.init(label: "并行队列",
                                   qos: .userInteractive,
                                   attributes: .concurrent)
        for i in 1...10 {
            q.async {
                print("任务\(i) : \(Thread.current)")
            }
        }
        
        self.updateResult(new: "开启多条线程,并发执行任务,这里面任务执行顺序: 无规则")
    }
    
    
    @IBAction func async_Serial(_ sender: Any) {
        let q = DispatchQueue.init(label: "串行队列")
        for i in 1...10 {
            q.async {
                print("任务\(i) : \(Thread.current)")
            }
        }
        self.updateResult(new: "开启一条线程,串行执行任务,任务: 顺序执行")
        
    }
    
    
    @IBAction func sync_Concurrent(_ sender: Any) {
        let q = DispatchQueue.init(label: "并行队列",
                                   qos: .userInteractive,
                                   attributes: .concurrent)
        for i in 1...10 {
            q.sync {
                print("任务\(i) : \(Thread.current)")
            }
        }
        self.updateResult(new: "不开启线程,串行执行任务,任务: 顺序执行")
        
    }
    
    @IBAction func sync_Serial(_ sender: Any) {
        let q = DispatchQueue.init(label: "串行队列")
        for i in 1...10 {
            q.sync {
                print("任务\(i) : \(Thread.current)")
            }
        }
        self.updateResult(new: "不开启线程,串行执行任务,任务: 顺序执行")
    }
    
    @IBAction func async_Main(_ sender: Any) {
        //在使用的时候, 我们一般不去创建并行队列, 而是使用系统为我们提供的全局的并行队列:
        DispatchQueue.main.async {
            for i in 1...10 {
                print("任务\(i) : \(Thread.current)")
            }
        }
        self.updateResult(new: "不开启线程,串行执行任务,任务: 顺序执行")
    }
    
    @IBAction func sync_Main(_ sender: Any) {
        self.updateResult(new: "这里不能 同步 + 主队列 的方式,会导致死锁\n当前任务正在运行,此时添加新任务\n下一个任务是新增的同步函数+主队列,并且要求所在线程立即执行\n系统无法在队列中的当前任务没有处理完之前切换任务,所以程序会崩溃\n")
        
    }
    
    //其他方法
    @IBAction func gcd_Communication(_ sender: Any) {
        self.setupImageView()
        print("请求前线程 : \(Thread.current)")
        //开启子线程,然后再在主线程中更新UI
        DispatchQueue.global().async {
            self.showImage()
        }
    }
    
    @IBAction func gcd_barrier_async(_ sender: Any) {
        //这里做一个例子,总共10个任务,每完成2个任务之后等待2秒,接着继续完成下两个任务
        for _ in 1...5 {
            DispatchQueue.main.async(flags: .barrier) {
                print(self.currentTime())
                for i in 1...2 {
                    print("任务\(i) : \(Thread.current)")
                }
                sleep(2)
            }
        }
        print("done!")
        //暂时留一个小问题,就是这里的done!打印是比栅栏函数要快,如何做到done!是最后打印的?也就是操作线程的顺序
    }
    
    @IBAction func gcd_after(_ sender: Any) {
        let afterTime = DispatchTime.now() + .seconds(2)
        self.resultTF.text = "\(self.currentTime())\n"
        DispatchQueue.main.asyncAfter(deadline: afterTime) {
            self.setupImageView()
            self.resultTF.text = self.resultTF.text.appending(self.currentTime())
            let info = "\n当前线程 : \(Thread.current)\n"
            self.showImage()
            self.resultTF.text = self.resultTF.text.appending(info)
        }
    }
    
    @IBAction func gcd_one(_ sender: Any) {
        DispatchQueue.once(token: "token") {
            for i in 1...2 {
                print("任务\(i) : \(Thread.current)")
            }
        }
        self.updateResult(new: "执行性一次任务,再次点击操作,不再执行")
        
    }
    
    @IBAction func gcd_apply(_ sender: Any) {
        self.updateResult(new: "貌似没找到swift中的这个apply的使用方法")
    }
    
    @IBAction func gcd_group(_ sender: Any) {
        let queue = DispatchQueue(label: "组队列")
        let group = DispatchGroup()
        queue.async(group: group) {
            for i in 0...5 {
                print("任务\(i) : \(Thread.current)")
            }
        }
        
        let result = group.wait(timeout: .now() + 2.0)
        switch result {
        case .success:
            print("不超时, 上面的任务都执行完")
        case .timedOut:
            print("超时了, 上面的任务还没执行完执行这了")
        }
        
        group.notify(queue: queue) {
            print("回到队列")
        }
        print("done!")
    }
    
}




extension GCD_Demo {
    
    func gcdDes() {
        resultTF.isUserInteractionEnabled = false
        resultTF.text = "线程执行组合\n"
        resultTF.text = resultTF.text.appending("异步 : sync , 同步 : async\n")
        resultTF.text = resultTF.text.appending("01 异步+并发 ：开启多条线程，并发执行任务\n")
        resultTF.text = resultTF.text.appending("02 异步+串行 ：开启一条线程，串行执行任务\n")
        resultTF.text = resultTF.text.appending("03 同步+并发 ：不开线程，串行执行任务\n")
        resultTF.text = resultTF.text.appending("04 同步+串行 ：不开线程，串行执行任务\n")
        resultTF.text = resultTF.text.appending("05 异步+主队列 ：不开线程，在主线程中串行执行任务\n")
        resultTF.text = resultTF.text.appending("06 同步+主队列 ：不开线程，在主线程中串行执行任务（注意死锁发生）\n")
        resultTF.text = resultTF.text.appending("07 使用同步函数往当前串行队列中添加任务，会卡住当前的串行队列\n\n")
    }
    
    
    
    func downImage() {
        let imageUrl = URL(string: "http://g.hiphotos.baidu.com/baike/w%3D268%3Bg%3D0/sign=4b2b937f8bcb39dbc1c06050e82d6e19/342ac65c103853436d1d70b49913b07ecb808851.jpg")
        let request = URLRequest(url: imageUrl!)
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: request,
                                                completionHandler: { (location:URL?, response:URLResponse?, error:Error?)
                                                    -> Void in
                                                    guard let location = location else {
                                                        return
                                                    }
                                                    print("location:\(location)")
                                                    let locationPath = location.path
                                                    var documnets:String = NSHomeDirectory() + "/Documents/\(self.downloadCount).png"
                                                    let fileManager = FileManager.default
                                                    while fileManager.fileExists(atPath: documnets) {
                                                        self.downloadCount = self.downloadCount + 1
                                                        documnets = NSHomeDirectory() + "/Documents/\(self.downloadCount).png"
                                                        
                                                    }
                                                    try! fileManager.moveItem(atPath: locationPath, toPath: documnets)
                                                    print("new location:\(documnets)")
        })
        downloadTask.resume()
    }
    
    func showImage()  {
        print("请求中线程 : \(Thread.current)")
        let imageUrl = URL(string: "http://g.hiphotos.baidu.com/baike/w%3D268%3Bg%3D0/sign=4b2b937f8bcb39dbc1c06050e82d6e19/342ac65c103853436d1d70b49913b07ecb808851.jpg")
        let session  = URLSession.shared
        let dataTask = session.dataTask(with: imageUrl!, completionHandler: { (data, respone, error) in
            guard let data = data else {
                return
            }
            DispatchQueue.main.sync {
                let image = UIImage(data: data)
                self.imageView.image = image
            }
        })
        dataTask.resume()
    }
    
    
    
    
    
    func currentTime() -> String {
        let now = NSDate()
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        return dformatter.string(from: now as Date)
    }
    
    
    func setupImageView()  {
        imageView.backgroundColor = UIColor.gray
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissFromSuperview))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
        self.view.addSubview(imageView)
    }
    @objc func dismissFromSuperview() {
        print("dismiss")
        self.imageView.removeFromSuperview()
    }
    
    func updateResult(new: String) {
        DispatchQueue.main.async {
            self.resultTF.text = new
        }
    }
}


public extension DispatchQueue {
    private static var _onceTracker = [String]()
    //在swift 3中原有的Dispatch once已经被废弃了。但是可以通过给DispatchQueue实现一个扩展方法来实现原有的功能。
    public class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
}


