//
//  ViewController.swift
//  MyText
//
//  Created by MacBook Pro on 2020/4/2.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import Cocoa
import AppKit
import HotKey
import Carbon
//运行命令行程序
func runCommand(launchPath: String, arguments: [String]) -> String {
    let pipe = Pipe()
    let file = pipe.fileHandleForReading
    
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments
    task.standardOutput = pipe
    task.launch()
    
    let data = file.readDataToEndOfFile()
    return String(data: data, encoding: String.Encoding.utf8)!
}
//JSON转字典
func getDictionaryFromJSONString(jsonString:String) ->NSDictionary{

    let jsonData:Data = jsonString.data(using: .utf8)!

    let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
    if dict != nil {
        return dict as! NSDictionary
    }
    return NSDictionary()
}
func gettokenData(API_Key: String,Secret_Key: String)->String
{
    let urlString:String = "https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=" + API_Key + "&client_secret=" + Secret_Key
    var myurl:NSURL!
    myurl = NSURL(string: urlString)
//    let request = NSMutableURLRequest(url: myurl)
//    request.HTTPMethod = "GET"
    var request:NSURLRequest = NSURLRequest(url: myurl as URL)
    
    var response:URLResponse?
    
    do{
        let received:NSData? = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response) as NSData
        let datastring = NSString(data: received! as Data, encoding: String.Encoding.utf8.rawValue)
        print(datastring)
        if let retString = datastring as? String
        {
            return retString
        }
        
    }catch let error as NSError{
        print(error.code)
        print(error.description)
        return (error.description as String)
    }
    return String("Error")
}
func getToken(tokenData: String)->String{
    let tokenDict = getDictionaryFromJSONString(jsonString: tokenData as String)
    
    let token = tokenDict["access_token"]
    
    if let tokenstr = token as? String{
        return tokenstr
    }
    return ""
}
//获取剪贴板中的png图片
func GetPastePNG() -> Data {
    let pasteboard = NSPasteboard.general
//    let data_type = pasteboard.types
//    Mac截图为png格式
    let ss = pasteboard.data(forType: NSPasteboard.PasteboardType.png)
    if let unwarpedss = ss{
        return unwarpedss
    }
    return Data()
}

func PNGBase64URL(PngData: Data) -> String {
    var bitmap: NSBitmapImageRep! = NSBitmapImageRep(data: PngData)
    var pngimage = bitmap.representation(using: NSBitmapImageRep.FileType.png, properties: [:])
//    Base64加密
    let base64 = pngimage!.base64EncodedString(options: .endLineWithLineFeed)
//    URL加密
    let imageString = base64.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
    if let unwarpedStr = imageString{
        return unwarpedStr
    }
    return "Error"
}

func Connect2Baidu(Token: String,imageString: String) -> NSData {
    var request_url = "https://aip.baidubce.com/rest/2.0/ocr/v1/general_basic"
    let params = ("image=") + imageString
    request_url = request_url + "?access_token=" + Token
    
    var myurl:NSURL!
    myurl = NSURL(string: request_url)
    let request = NSMutableURLRequest(url: myurl as URL)
    request.httpMethod = "POST"
    request.addValue("application/x-www-form-urlencoded",forHTTPHeaderField: "Content-Type")
    
    let body = params
    request.httpBody = body.data(using: String.Encoding.utf8)
    
    var response:URLResponse?
    
    do{
    //发出请求
        let received:NSData? = try NSURLConnection.sendSynchronousRequest(request as URLRequest,returning: &response) as NSData
        if let unwarpedReceive = received{
            return unwarpedReceive
        }
    }catch let error as NSError{
        //打印错误消息
        print(error.code)
        print(error.description)
    }
    
    return NSData()
}

func GetStringinData(BaiduData: NSData) -> String {
    
    let datastring = NSString(data:BaiduData as Data, encoding: String.Encoding.utf8.rawValue)
    let jsonDictionary = getDictionaryFromJSONString(jsonString: datastring! as String)
    
    var resultstr = ""
    
    let words = jsonDictionary["words_result"]
    if let results = words as? NSArray{
        for item in results{
            if let worddir = item as? NSDictionary{
                for (_,value) in worddir{
//                    print(value)
                    if let tempstr = value as? String
                    {
//                        一步步拿出最终的Str结果
                        resultstr = resultstr + tempstr + "\n"
                    }
                    
                }
            }
//            print("-------")
        }
    }
//    print(resultstr)
    return resultstr
}

func Write2Pasteboard(ResultStr: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
    let b = pasteboard.setString(ResultStr, forType: NSPasteboard.PasteboardType.string)
    print(b)
}


func MyOCR(){
    //运行截图程序
    let s = runCommand(launchPath: "/usr/sbin/screencapture", arguments: ["-c","-i"])
    print(s)
    
    let pngdata = GetPastePNG()
    let Pngurl = PNGBase64URL(PngData: pngdata)
    let theTokenData = gettokenData(API_Key: "Li5lsMvKMhtyPtEWFZ42gYLS", Secret_Key: "nr190gGFG8NpLVMGGfIyK8kGjaGUpFHT")
//    print(theToken)
    let theToken = getToken(tokenData: theTokenData)
    let ReturnData = Connect2Baidu(Token: theToken as String, imageString: Pngurl)
    
//    let ReturnData = Connect2Baidu(Token: "24.31dbd6ebe97a4d7e951fee369cb4b6ec.2592000.1588312971.282335-19176914", imageString: Pngurl)
    let finalStr = GetStringinData(BaiduData: ReturnData)
    Write2Pasteboard(ResultStr: finalStr)
    print(finalStr)
    
    
    
    
}

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        register(self)
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    
    

    private var hotKey: HotKey? {
        didSet {
            guard let hotKey = hotKey else {
                print("Unregistered")
                return
            }

            print("Registered")

            hotKey.keyDownHandler = { [weak self] in
                print("Pressed at \(Date())")
                MyOCR()
            }
        }
    }


    // MARK: - Actions

    @IBAction func unregister(_ sender: Any?) {
        hotKey = nil
    }

    @IBAction func register(_ sender: Any?) {
        hotKey = HotKey(keyCombo: KeyCombo(key: .one, modifiers: [.command, .shift]))
    }



}

