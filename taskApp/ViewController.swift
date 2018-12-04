import UIKit
import RealmSwift
import UserNotifications


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource ,UISearchBarDelegate{
// tableview定義
    @IBOutlet weak var tableview: UITableView!
//    realmインスタンス取得
    let realm = try! Realm()
//    タスク全数
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
//    検索結果入れる
    var serchresult : String = ""
//    searchBar 入力用
    @IBOutlet weak var searchText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
//    ○
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
//    ○taskの個数返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
// ○セルの内容表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        taskに全数を入れる。
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.category
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        func searchBotton(){}
        
        return cell
        
   
        
    }
//    ○タップされた後の挙動
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
//    ○削除できる
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        return .delete
    }
//    ○セルのデータ渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = tableview.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = Date()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
//    ○戻りの時のデータ更新
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableview.reloadData()
    }
//    ○
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let task = self.taskArray[indexPath.row]
            
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
    
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    @IBOutlet weak var kakuninlabel: UILabel!
    @IBAction func searchBotton(_ sender: Any) {
//        検索ボタンを押して、テキストラベル取得
        serchresult = searchText.text!
        print(serchresult)
        kakuninlabel.text = serchresult
//        テキストラベルと同じ、カテゴリーのCellをtableviewに表示させる。
        let categoryCategory = NSPredicate(format:  "category = %@", serchresult)
        let categoryResult = realm.objects(Task.self).filter(categoryCategory)
//        taskArrayに検索後のタスクを表示
        taskArray = categoryResult
//        ロードする
        tableview.reloadData()
    }
}



















