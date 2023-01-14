//
//  SSLanguage.swift
//  Huatao
//
//  Created by minse on 2023/1/13.
//

import Foundation

enum LanguageType: String {
    case none
    case en = "en"           // 英文
    case zhHant = "zh-Hant"  // 繁体中文
    case zhHans = "zh-Hans"  // 简体中文
    
    func infoStr() -> String {
        switch self {
        case .none:
            return ""
        case .en:
            return "English"
        case .zhHant:
            return "繁體中文"
        case .zhHans:
            return "简体中文"
        }
    }
    
}

struct NationalString {
    let hans: String
    let hant: String
    let en: String
}

/// 多语言
class SSLanguage {
    static let shared = SSLanguage()
    private init() {
        reloadBundle()
    }
    
    var curLBundle: Bundle?
    var curLType: LanguageType = .none
    let LocalLanguageKey = "LocalLanguageKey"
    
    func setupType(theT: LanguageType) {
        UserDefaults.standard.setValue(theT.rawValue, forKey: LocalLanguageKey)
        reloadBundle()
    }
    
    func reloadBundle() {
        var localLanguage = ""
        if let local = UserDefaults.standard.string(forKey: LocalLanguageKey) {
            localLanguage = local
            if let type = LanguageType(rawValue: localLanguage) {
                curLType = type
            }
        } else {
            if let sysL = Locale.preferredLanguages.first {
                if sysL.hasPrefix("zh-") {
                    if sysL.hasPrefix("zh-Hans") {
                        localLanguage = LanguageType.zhHans.rawValue
                        curLType = .zhHans
                    } else {
                        localLanguage = LanguageType.zhHant.rawValue
                        curLType = .zhHant
                    }
                } else {
                    localLanguage = LanguageType.en.rawValue
                    curLType = .en
                }
            } else {
                localLanguage = LanguageType.en.rawValue
                curLType = .en
            }
        }
        
        guard let curBPath = Bundle.main.path(forResource: localLanguage, ofType: "lproj") else { return }
        curLBundle = Bundle(path: curBPath)
    }
    
    func localized(_ string: NationalString) -> String {
        switch curLType {
        case .none:
            return string.hans
        case .en:
            return string.en
        case .zhHant:
            return string.hant
        case .zhHans:
            return string.hans
        }
    }
}

extension String {
    func localized(_ arguments: CVarArg...) -> String {
        guard let bundle = SSLanguage.shared.curLBundle else { return NSLocalizedString(self, comment: "") }
        let format = NSLocalizedString(self, tableName: "languageData", bundle: bundle, value: "", comment: "")
        return String.localizedStringWithFormat(format, arguments)
    }
}

