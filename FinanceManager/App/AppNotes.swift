import UIKit

enum AppNotes: String {
    case didReceivePushURL
    case didAuthorizeUser // пользователь авторизован
    case didLogOutUser // пользователь разлогинен
    case didUpdateUserInfo // любое изменение curentUser в UserManager
    case didUpdateUserInfoFromAPI // получение информации о юзере из АПИ
//    case didUpdateUserBalance // получение информации о балансе из АПИ
    case didUpdateCart // получение информации о корзине из АПИ
    
    case stakeDidChangeRate
    case cartButtonDidUpdate
    case pageSheetDidAppear // Only iOS 13
    case pageSheetDidDisappear // Only iOS 13
    case currencyDidUpdate
    case choosenQuestionDidUpdate
    case expressSystemPayItemDidSelect
    case chooseSystemSizeButtonDidSelect
    case sessionIsBroken
    case didReceiveAppsFlyerEvent
    case didPassSecond
    case didChangeFavoriteSports
    case didChangedTheme
    case didChangedNavigationStyle
    case didChangedMatchCellStyle
    case needUpdateLiveChat
    case needUpdateSideMenu
    case languageDidUpdate
    case messagesDidReceive
    case didChangeVideoDownloadProgress
    case didRegisterForRemoteNotifications
    case didFailRegisterForRemoteNotifications
    case didChangeRemoteNotificationStatus
    case liveMatchesViewControllerDidLoad
    case liveMatchesViewControllerFirstlyDidAppear
    case requestOpenHistory
    case didUpdateBetsHistoryByBetId
    case didMakeSingleBet
    case didApplyFakePromoCode
    case webViewScreenDidReceiveReturnURL
    case didMakeVirtualBet
    case didSelectTotoCoupon
    case didUpdateTotoStakes
    case didUpdateCartAlertData
    case didUpdateCartAlertHeight
    case didChangedRateWhileBet
    case didRequestToUpdateCart
    case didScrollToUnvailable
    case didDeleteUnvailableStakesInCart

    case didChangeLiveChatState
    case didUpdateLiveChat
    case didUpdateFavoriteMatches
    case didAddFavoriteMatch
    case didSentRightEmailCode
    case didUpdateSBAUserInfo
    case didUpdateSBABonusTime
    case didUpdateSBABonusBlur
    case didReceiveSMSCode
    
    case didUpdateMatchesInfo
    case didUpdateFilterMatches
    
    // MARK: - Share
    case didSelectShareGif
    case didChangeShareSwitch
    
    // MARK: - UserFirendlyPromocodes
    case didRenameInvitePromocode
    
    // MARK: - VOIP
    case didChangeVOIPState
    
    case didFoundQRCode

    case didAddCustomLink
    
    case didUpdateFastBetMessage
    
    case didReceiveCupisV2RegSocketEvent

    case didUpdateKodMobiTimer

    var notification: Notification.Name {
        Notification.Name(rawValue: rawValue)
    }
}

enum IdentificationBetNotes: String {
    case didSelectFirstInfoButton
    case didSelectSecondInfoButton
    case previousState
    case nextState
    
    case sendIdent
    case sendDocuments
    case sentIdentError
    case sentIdentSuccess
    
    var notification: Notification.Name  {
        Notification.Name(rawValue: "IdentificationBet_\(self.rawValue)")
    }
}
