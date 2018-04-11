//
//  GlobalConstant.swift
//  SRIMCA
//
//  Created by ToShare Pty. Ltd on 9/22/17.
//  Copyright © 2017 ToShare Pty. Ltd. All rights reserved.
//

import Foundation
import UIKit

//Development
//let BASE_URL = "http://ec2-13-58-51-213.us-east-2.compute.amazonaws.com/development/api/"
//let PHOTO_BASE_URL = "http://ec2-13-58-51-213.us-east-2.compute.amazonaws.com/development/api"

//Live
let BASE_URL = "http://ec2-13-59-33-113.us-east-2.compute.amazonaws.com/development/api/"
let PHOTO_BASE_URL = "http://ec2-13-59-33-113.us-east-2.compute.amazonaws.com/development/api/"
let CERTIFICATE_URL = "http://ec2-13-59-33-113.us-east-2.compute.amazonaws.com/development/api/certificates/asset/"
let CLASS_URL = "http://ec2-13-59-33-113.us-east-2.compute.amazonaws.com/development/api/class/assets/"


let APP_VERSION = 1.0
let BUILD_VERSION = 1

let POLICE_CHECK_URL = "https://npcoapr.police.nsw.gov.au/aspx/dataentry/Introduction.aspx"

let ITUNES_URL = "https://itunes.apple.com/us/app/lit-nite/id1360588270?ls=1&mt=8"

let TERMS_CONDITIONS = "http://mylitnite.com/terms"

let stateArr : [String] = ["ACT", "JBT", "NSW", "NT", "QLD", "SA", "TAS", "VIC", "WA"]
let classLevelArr : [String] = ["Beginner", "Intermediate", "Advanced"]

struct SCREEN
{
    static var WIDTH = UIScreen.main.bounds.size.width
    static var HEIGHT = UIScreen.main.bounds.size.height
}

struct COLOR {
    static var APP_COLOR = "4BDAA7"
    static var BLACK_COLOR = "000000"
    static var WHITE_COLOR = "FFFFFF"
    static var DARK_TEXT = "555555"
    static var LIGHT_GRAY = "AAAAAA"
    static var SHADOW_GRAY = "D3D3D3"
    static var ORANGE_COLOR = "F9A955"
    
}

struct DATE_FORMAT {
    static var SERVER_DATE_FORMAT = "dd/MM/yyyy"
    static var SERVER_TIME_FORMAT = "HH:mm"
    static var SERVER_DATE_TIME_FORMAT = "dd/MM/yyyy HH:mm"
    static var DISPLAY_DATE_FORMAT = "dd/MM/yyyy"
    static var DISPLAY_TIME_FORMAT = "hh:mm a"
    static var DISPLAY_DATE_TIME_FORMAT = "dd/MM/yyyy HH:mm"
}

struct CONSTANT{
    static var DP_IMAGE_WIDTH     =  512
    static var DP_IMAGE_HEIGHT    =  512
}

struct IMAGE {
    static var USER_PLACEHOLDER = "user_avatar"
    static var CAMERA_PLACEHOLDER = "camera_icon"
}

struct STORYBOARD {
    static var MAIN = UIStoryboard(name: "Main", bundle: nil)
    static var CLASS = UIStoryboard(name: "Class", bundle: nil)
    static var BOOKING = UIStoryboard(name: "Booking", bundle: nil)
    static var MESSAGE = UIStoryboard(name: "Message", bundle: nil)
}

struct GOOGLE
{
    static var KEY = "AIzaSyCPCVymlzk8ZbtPfFOJuvqIpcUQiaXJ2IE" // tutableapp@gmail.com // tutable@2018
    static var CLIENT_ID = "199536116736-5d2msb7pgaeh8g7l9emptcnbl96somc1.apps.googleusercontent.com"
}

struct FACEBOOK {
    static var FB_KEY = "593587777700511"
    static var FB_SECRET = "68bd3f6e838f9ed1e68220e204c09406"
}

struct NOTIFICATION {
    static var UPDATE_CURRENT_USER_DATA     =   "UPDATE_CURRENT_USER_DATA"
    static var UPDATE_TAB_SELECTION         =   "UPDATE_TAB_SELECTION"
    static var REDIRECT_TO_NOTIFICATION     =   "REDIRECT_TO_NOTIFICATION"
    static var ON_UPDATE_ALL_USER           =   "ON_UPDATE_ALL_USER"
    static var ON_UPDATE_STORIES            =   "ON_UPDATE_STORIES"
    static var UPDATE_INBOX_LIST            =   "UPDATE_INBOX_LIST"
}

struct COREDATA {
    struct MESSAGE
    {
        static var TABLE_NAME = "Message"
        static var CHANNEL_ID = "channeld"
        static var msgID = "msgID"
        static var key = "key"
        static var SENDER = "sender"
        static var USER_NAME = "userName"
        static var RECEIVER = "receiver"
        static var OWNER_NAME = "ownerName"
        static var date = "date"
        static var text = "text"
        static var status = "status"
        static var type = "type"
        static var local_picture = "local_picture"
        static var remote_picture = "remote_picture"
    }
    struct USER
    {
        static var TABLE_NAME = "User"
        static var uID = "uID"
        static var name = "name"
        static var picture = "picture"
        static var last_seen = "last_seen"
    }
    
    struct FOLDER {
        static var CHAT_IMAGE = "chat_image"
    }
}

struct Platform {
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
    
}

