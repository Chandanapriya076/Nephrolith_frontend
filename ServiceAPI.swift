import Foundation

struct ServiceAPI {

    static let baseURL = "http://14.139.187.229:8081/oct/renal/"

    // Doctor
    static let doctorRegister = baseURL + "dsignup.php"
    static let doctorLogin    = baseURL + "dlogin.php"
    static let doctorProfile  = baseURL + "dprofile.php"
    static let doctorForgot   = baseURL + "dforgot.php"

    // Patient
    static let patientRegister = baseURL + "psignup.php"
    static let patientLogin    = baseURL + "plogin.php"
    static let patientProfile  = baseURL + "pprofile.php"
    static let patientForgot   = baseURL + "pforgot.php"

    // Diagnosis & Reports
    static let diagnosis   = baseURL + "diagnosis.php"
    static let pending     = baseURL + "get_pending_reviews.php"
    static let lastReport  = baseURL + "last_report.php"
    static let report      = baseURL + "report.php"

    // History
    static let getHistory  = baseURL + "gethistory.php"
    static let addHistory  = baseURL + "addhistory.php"

    // Policies
    static let privacyPolicy = baseURL + "privacy_policy.php"
}

