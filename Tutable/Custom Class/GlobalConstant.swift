//
//  GlobalConstant.swift
//  SRIMCA
//
//  Created by ToShare Pty. Ltd on 9/22/17.
//  Copyright © 2017 ToShare Pty. Ltd. All rights reserved.
//

import Foundation
import UIKit

//Live
let BASE_URL = "https://backend.tutable.com.au/production/api/"
//let BASE_URL = "https://backend.tutable.com.au/development/api/"
let PHOTO_BASE_URL = BASE_URL
let CERTIFICATE_URL = BASE_URL + "api/certificates/asset/"
let CLASS_URL = BASE_URL + "api/class/assets/"


let APP_VERSION = 1.0
let BUILD_VERSION = 1

let POLICE_CHECK_URL = "https://npcoapr.police.nsw.gov.au/aspx/dataentry/Introduction.aspx"
let CHILDREN_CHECK_URL = "https://www.service.nsw.gov.au/transaction/apply-working-children-check"

let ITUNES_URL = "https://itunes.apple.com/us/app/lit-nite/id1360588270?ls=1&mt=8"

let TERMS_CONDITIONS = "http://mylitnite.com/terms"

let stateArr : [String] = ["ACT", "NSW", "NT", "QLD", "SA", "TAS", "VIC", "WA"]
let classLevelArr : [String] = ["Beginner", "Intermediate", "Advanced"]

let VALID_USER_AGE = 13

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
    static var DP_IMAGE_WIDTH     =  800
    static var DP_IMAGE_HEIGHT    =  800
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

struct STRIPE {
//    static var STRIPE_PUB_KEY = "pk_test_u3xxbQe9ozU9Ql5bwQMFyPzh"
//    static var STRIPE_SECRET_KEY = "sk_test_SRQOZSEF09YCrg9bCCDeF4Qa"
    static var STRIPE_PUB_KEY = "pk_live_g4fAnJnNuPRgdNfOzqXrzPp2"
    static var STRIPE_SECRET_KEY = "sk_live_ApH1O1WMDZbzrKacgzpsUDiG"
}

struct NOTIFICATION {
    static var UPDATE_CURRENT_USER_DATA     =   "UPDATE_CURRENT_USER_DATA"
    static var UPDATE_TAB_SELECTION         =   "UPDATE_TAB_SELECTION"
    static var REDIRECT_TO_MESSAGE          =   "REDIRECT_TO_MESSAGE"
    static var ON_UPDATE_ALL_USER           =   "ON_UPDATE_ALL_USER"
    static var ON_UPDATE_STORIES            =   "ON_UPDATE_STORIES"
    static var UPDATE_INBOX_LIST            =   "UPDATE_INBOX_LIST"
    static var UPDATE_MESSAGE_BADGE         =   "UPDATE_MESSAGE_BADGE"
}

struct COREDATA {
    struct MESSAGE
    {
        static var TABLE_NAME = "Message"
        static var key = "key"
        static var msgID = "msgID"
        static var otherUserId = "otherUserId"
        static var date = "date"
        static var text = "text"
        static var status = "status"
    }
    struct USER
    {
        static var TABLE_NAME = "User"
        static var id = "id"
        static var name = "name"
        static var email = "email"
        static var picture = "picture"
        static var last_seen = "last_seen"
    }
}

struct Platform {
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
    
}

