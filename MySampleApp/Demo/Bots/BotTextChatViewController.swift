//
//  BotTextChatViewController.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.16
//

import Foundation
import JSQMessagesViewController
import AWSLex
import AWSMobileHubHelper

let ClientSenderId = "Client"
let ServerSenderId = "Server"

/// Manages a text-to-text conversation with a bot
class BotTextChatViewController: JSQMessagesViewController, JSQMessagesComposerTextViewPasteDelegate {
    
    // The bot name
    var botName: String?
    
    // The bot region
    var botRegion: AWSRegionType?
    
    // The bot alias
    var botAlias: String?
    
    // The messages communicated between client and server(bot)
    var messages: [JSQMessage]?
    
    // The interaction kit client
    var interactionKit: AWSLexInteractionKit?
    
    // The session attributes
    var sessionAttributes: [AnyHashable: Any]?
    
    // Contents of outgoing image
    var outgoingBubbleImageData: JSQMessagesBubbleImage?
    
    // Contents of incoming image
    var incomingBubbleImageData: JSQMessagesBubbleImage?
    
    // used to store task completion source of interaction kit
    var textModeSwitchingCompletion: AWSTaskCompletionSource<NSString>?
    
    // client image
    var clientImage: JSQMessagesAvatarImage?
    
    // server(bot) image
    var serverImage: JSQMessagesAvatarImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup service configuration for bots
        let configuration = AWSServiceConfiguration(region: botRegion!, credentialsProvider: AWSIdentityManager.default().credentialsProvider)
        // setup interaction kit configuration
        let botConfig = AWSLexInteractionKitConfig.defaultInteractionKitConfig(withBotName: botName!, botAlias: botAlias!)
        
        // disable automatic voice playback for text demo
        botConfig.autoPlayback = false
        
        // register the interaction kit client
        AWSLexInteractionKit.register(with: configuration!, interactionKitConfiguration: botConfig, forKey: botName!)
        // fetch and set the interaction kit client
        self.interactionKit = AWSLexInteractionKit.init(forKey: botName!)
        // set the interaction kit delegate
        self.interactionKit?.interactionDelegate = self
        
        // setup JSQMessagesViewController configuration
        self.showLoadEarlierMessagesHeader = false
        
        
        
        // Initialize avatars for client and server
        
        clientImage = JSQMessagesAvatarImageFactory().avatarImage(with: #imageLiteral(resourceName: "UserIconBots"))
        serverImage = JSQMessagesAvatarImageFactory().avatarImage(with: #imageLiteral(resourceName: "BotsServerIcon"))
        
        // set the keyboard type
        self.inputToolbar.contentView?.textView?.keyboardType = UIKeyboardType.default
        
        // initialize the messages list
        self.messages = [JSQMessage]()
        
        // set the colors for message bubbles
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.outgoingBubbleImageData = bubbleFactory.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        self.incomingBubbleImageData = bubbleFactory.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        
        self.inputToolbar.contentView?.leftBarButtonItem = nil
    }
    
    // MARK: - JSQMessagesViewController delegate methods
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages?.append(message)
        
        if let textModeSwitchingCompletion = textModeSwitchingCompletion {
            textModeSwitchingCompletion.set(result: text as NSString)
            self.textModeSwitchingCompletion = nil
        }
        else {
            self.interactionKit?.text(inTextOut: text)
        }
        self.finishSendingMessage(animated: true)
    }
    
    override func senderDisplayName() -> String {
        return "Joe"
    }
    
    override func senderId() -> String {
        return ClientSenderId
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        
        return self.messages![indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didDeleteMessageAt indexPath: IndexPath) {
        //DO NOTHING
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        let message = self.messages![indexPath.item]
        if (message.senderId == self.senderId()) {
            return self.outgoingBubbleImageData!
        }
        return self.incomingBubbleImageData!
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        let message = messages![indexPath.item]
        if message.senderId == ClientSenderId {
            return self.clientImage
        }
        return self.serverImage
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let messages = messages {
            return messages.count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = (super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell)
        let msg = self.messages?[indexPath.item]
        if !msg!.isMediaMessage {
            if (msg?.senderId == self.senderId()) {
                cell.textView?.textColor = UIColor.black
            }
            else {
                cell.textView?.textColor = UIColor.white
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.item % 3 == 0 {
            let message = self.messages?[indexPath.item]
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message!.date)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        let message = self.messages?[indexPath.item]
        
        // iOS7-style sender name labels
        if (message?.senderId == self.senderId()) {
            return nil
        }
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages?[indexPath.item - 1]
            if (previousMessage?.senderId == message?.senderId) {
                return nil
            }
        }
        
        // Don't specify attributes to use the defaults.
        return NSAttributedString(string: message!.senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellBottomLabelAt indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }
    
    func composerTextView(_ textView: JSQMessagesComposerTextView, shouldPasteWithSender sender: Any) -> Bool {
        return true
    }
    
}

// MARK: Bot Interaction Kit
extension BotTextChatViewController: AWSLexInteractionDelegate {
    
    func interactionKit(_ interactionKit: AWSLexInteractionKit, onError error: Error) {
        print("Error occurred: \(error)")
    }
    
    func interactionKit(_ interactionKit: AWSLexInteractionKit, switchModeInput: AWSLexSwitchModeInput, completionSource: AWSTaskCompletionSource<AWSLexSwitchModeResponse>?) {
        self.sessionAttributes = switchModeInput.sessionAttributes
        DispatchQueue.main.async(execute: {
            let message: JSQMessage
            // Handle a successful fulfillment
            if (switchModeInput.dialogState == AWSLexDialogState.readyForFulfillment) {
                // Currently just displaying the slots returned on ready for fulfillment
                if let slots = switchModeInput.slots {
                    message = JSQMessage(senderId: ServerSenderId, senderDisplayName: "", date: Date(), text: "Slots:\n\(slots)")
                    self.messages?.append(message)
                    self.finishSendingMessage(animated: true)
                }
            } else {
                message = JSQMessage(senderId: ServerSenderId, senderDisplayName: "", date: Date(), text: switchModeInput.outputText!)
                self.messages?.append(message)
                self.finishSendingMessage(animated: true)
            }
            
        })
        //this can expand to take input from user.
        let switchModeResponse = AWSLexSwitchModeResponse()
        switchModeResponse.interactionMode = AWSLexInteractionMode.text
        switchModeResponse.sessionAttributes = switchModeInput.sessionAttributes
        completionSource?.set(result: switchModeResponse)
    }
    
    /*
     * Sent to delegate when the Switch mode requires a user to input a text. You should set the completion source result to the string that you get from the user. This ensures that the session attribute information is carried over from the previous request to the next one.
     */
    func interactionKitContinue(withText interactionKit: AWSLexInteractionKit, completionSource: AWSTaskCompletionSource<NSString>) {
        textModeSwitchingCompletion = completionSource
    }
}
