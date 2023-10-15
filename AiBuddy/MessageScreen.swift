//
//  MessageScreen.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/7/23.
//

import SwiftUI
import Combine
import CoreData
import Speech
import AVFoundation

struct NavigationBar: View {
    
    var dismiss: () -> Void
    
    var character: Character
    @Binding var refreshID: UUID
    @Binding var isTextFieldFocused: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                // Handle back button action
                // Refresh HomeScreen for most recent message preview
                refreshID = UUID()
                // Set the text field to not be focused
                isTextFieldFocused = false
                // Dismiss current screen
                dismiss()
            }) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(character.name)
                .font(.headline)
            Spacer()
            EmptyView() // Add a placeholder for any additional buttons/icons
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

struct TimestampView: View {
    var date: Date
    
    var body: some View {
        HStack {
            Spacer()
            Text(date.longFormattedString)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
            Spacer()
        }
    }
}

struct MessageBubbleView: View {
    var message: Message
    var index: Int
    var messageIndexToScrollTo: Int?
    @Binding var selectedMessage: Message?
    @Binding var isTextFieldFocused: Bool
    @Binding var messages: [Message]
    var proxy: ScrollViewProxy // Include proxy property
    var character: Character
    
    var bottomMessageIndex: Int { messages.indices.last ?? 0 }
    
    func scrollToBottom(with proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(bottomMessageIndex, anchor: .bottom)
        }
    }
    
    var body: some View {
        MessageBubble(text: message.content, timestamp: message.timestamp, isSentByUser: message.isSentByUser)
            .id(index)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            //scroll to selected message from prior search
                            if let scrollToIndex = messageIndexToScrollTo, index == scrollToIndex {
                                let minY = geometry.frame(in: .global).minY
                                let height = geometry.size.height
                                proxy.scrollTo(index, anchor: .top)
                            } else {
                                //scroll to bottom (most recent message) if no selectedIndex
                                scrollToBottom(with: proxy)
                            }
                        }
                }
            )
            .contextMenu {
                Button(action: {
                    // Delete character action
                    selectedMessage = message
                }) {
                    Text("Delete")
                    Image(systemName: "trash.fill")
                }
            }
            .onChange(of: isTextFieldFocused) { isFocused in
                if isFocused {
                    scrollToBottom(with: proxy)
                }
            }
            .actionSheet(item: $selectedMessage) { message in
                ActionSheet(
                    title: Text(""),
                    message: Text("This message will be deleted."),
                    buttons: [
                        .destructive(Text("Delete"), action: {
                            handleDeleteMessage(message)
                        }),
                        .cancel(Text("Cancel"))
                    ]
                )
            }
    }
    
    func handleDeleteMessage(_ message: Message) {
        // Copy messageContent
        let text = message.content
        
        // Delete message
        Constants.context.delete(message)
        
        // Remove the message from the messages array to properly update this view
        if let index = messages.firstIndex(of: message) {
            messages.remove(at: index)
        }
        
        // If the last text in the chain was the one deleted, update the lastText and last modified date of the corresponding character/contact
        if text == character.lastText {
            if let lastMessage = messages.last {
                character.lastText = lastMessage.content
                character.modified = lastMessage.timestamp
            } else {
                character.lastText = ""
            }
        }
        
        // Save changes to core data
        PersistenceController.shared.saveContext()
    }
}


struct MessageList: View {
    
    @Binding var isTextFieldFocused: Bool
    @Binding var messages: [Message]
    @Binding var selectedMessage: Message?
    @State private var scrollOffset: CGFloat = 0
    var messageIndexToScrollTo: Int?
    var bottomMessageIndex: Int { messages.indices.last ?? 0 }
    var character: Character // does this need to be binding var?
    
    func scrollToBottom(with proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(bottomMessageIndex, anchor: .bottom)
        }
    }
    
    func getKeyboardHeight() -> CGFloat {
        return UIScreen.main.bounds.height > 800 ? 300 : 200
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages.indices, id: \.self) { index in
                        if index == 0 || messages[index].timestamp.timeIntervalSince(messages[index-1].timestamp) >= 3600 {
                            
                            TimestampView(date: messages[index].timestamp)
                        }
                        MessageBubbleView(
                            message: messages[index],
                            index: index,
                            messageIndexToScrollTo: messageIndexToScrollTo,
                            selectedMessage: $selectedMessage,
                            isTextFieldFocused: $isTextFieldFocused,
                            messages: $messages,
                            proxy: proxy,
                            character: character
                        )
                        //                        MessageBubble(text: messages[index].content, timestamp: messages[index].timestamp, isSentByUser: messages[index].isSentByUser)
                        //                            .id(index) // Ensure each message has a unique ID
                        //                            .background(
                        //                                GeometryReader { geometry in
                        //                                    Color.clear
                        //                                        .onAppear {
                        //                                            //scroll to selected message from prior search
                        //                                            if let scrollToIndex = messageIndexToScrollTo, index == scrollToIndex {
                        //                                                let minY = geometry.frame(in: .global).minY
                        //                                                let height = geometry.size.height
                        //                                                //                                                let offset = minY + height
                        //                                                proxy.scrollTo(index, anchor: .top)
                        //                                            } else {
                        //                                                //scroll to bottom (most recent message) if no selectedIndex
                        //                                                scrollToBottom(with: proxy)
                        //                                            }
                        //                                        }
                        //                                }
                        //                            )
                        //                            .contextMenu {
                        //                                Button(action: {
                        //                                    // Delete character action
                        //                                    selectedMessage = messages[index]
                        //                                }) {
                        //                                    Text("Delete")
                        //                                    Image(systemName: "trash.fill")
                        //                                }
                        //                            }
                        //                    }
                        //                    .onChange(of: messages) { _ in
                        //                        // Scroll to bottom on message change
                        //                        scrollToBottom(with: proxy)
                        //                    }
                        //                    .onChange(of: isTextFieldFocused) { isFocused in
                        //                        if isFocused {
                        //                            scrollToBottom(with: proxy)
                        //                        }
                        //                    }
                        //                    .actionSheet(item: $selectedMessage) { message in
                        //                        ActionSheet(
                        //                            title: Text(""),
                        //                            message: Text("This message will be deleted."),
                        //                            buttons: [
                        //                                .destructive(Text("Delete"), action: {
                        //                                    // Copy messageContent
                        //                                    let text = message.content
                        //
                        //                                    // Delete message
                        //                                    Constants.context.delete(message)
                        //
                        //                                    // Remove the message from the messages array to properly update this view
                        //                                    let index = messages.firstIndex(of: message)!
                        //                                    messages.remove(at: index)
                        //
                        //                                    // If the last text in the chain was the one deleted, update the lastText and last modified date of the corresponding character/contact
                        //                                    if text == character.lastText {
                        //                                        if let lastMessage = messages.last {
                        //                                            character.lastText = lastMessage.content
                        //                                            character.modified = lastMessage.timestamp
                        //                                        } else {
                        //                                            character.lastText = ""
                        //                                        }
                        //                                    }
                        //
                        //                                    // Save changes to core data
                        //                                    PersistenceController.shared.saveContext()
                        //                                }),
                        //                                .cancel(Text("Cancel"))
                        //                            ]
                        //                        )
                    }
                }
                .padding(.horizontal)
                .offset(y: scrollOffset)
                .allowsHitTesting(false) // Allow gestures to pass through
                .onChange(of: isTextFieldFocused) { focused in
                    print("changedddddddd")
                    if focused {
                        UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            
            .gesture(DragGesture()
                .onChanged { gesture in
                        // Detect scroll position
                print("gesture is CHANGGINGGGG")
                    print("Y POINT: \(gesture.location.y)")
                    print("end point prediction: \(gesture.predictedEndLocation.y)")
                        let offset = gesture.translation.height
                        let predictedEndLocation = gesture.predictedEndLocation.y
                    let textfieldViewHeight = 100.0
                        scrollOffset = offset
                        print(scrollOffset)
                        // Dismiss keyboard when scrolling downward past keyboard height
                    if offset > 0 && predictedEndLocation > (getKeyboardHeight() - textfieldViewHeight) {
                        print("CHAHAHAHANGED")
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
//                    if offset > 0 && offset > getKeyboardHeight() {
//                        print("CHAHAHAHANGED")
//                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                    }
                }
                .onEnded { gesture in
                    // Additional code to run when dragging ends, if needed
                    // Detect scroll position
                    print("gesture is ENDINGGGGG")
                    let offset = gesture.translation.height
                    scrollOffset = offset
                    print(scrollOffset)
                    // Dismiss keyboard when scrolling downward past keyboard height
                    if offset > 0 && offset > getKeyboardHeight() {
                        print("ENDINNGGGG")
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }

            )
        }
        
    }
}

//struct TextInputFieldView: View {
//    @Binding var text: String
//    var sendAction: () async -> Void
//
//    var body: some View {
//        HStack {
//            TextField("Type a message...", text: $text)
//                .padding(10)
//                .background(Color(.systemGray5))
//                .clipShape(RoundedRectangle(cornerRadius: 20))
//                .onTapGesture {
//                    // Assuming you want to set isTextFieldFocused here
//                }
//
//            Button {
//                Task {
//                    await sendAction()
//                }
//            } label: {
//                Image(systemName: "paperplane")
//                    .font(.headline)
//            }
//
////
////            Button(action: sendAction) {
////                Image(systemName: "paperplane")
////                    .font(.headline)
////            }
//        }
//        .padding()
//    }
//}

extension Calendar {
    func isDateInLastWeek(_ date: Date) -> Bool {
        guard let oneWeekAgo = self.date(byAdding: .day, value: -7, to: Date()) else {
            return false
        }
        return date > oneWeekAgo
    }
}

extension Date {
    
    var localizedMediumDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE, M d"
        return formatter.string(from: self)
    }
    
    var localizedDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }
    
    var dayOfWeekString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
    
    var localizedTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    var formattedString: String {
        if Calendar.current.isDateInToday(self) {
            return localizedTimeString
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        } else if Calendar.current.isDateInLastWeek(self) {
            return dayOfWeekString
        } else {
            return "\(localizedMediumDateString) at \(localizedTimeString)"
        }
    }
    
    var longFormattedString: String {
        if Calendar.current.isDateInToday(self) {
            return localizedTimeString
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday \(localizedTimeString)"
        } else if Calendar.current.isDateInLastWeek(self) {
            return "\(dayOfWeekString) \(localizedTimeString)"
        } else {
            return localizedDateString
        }
    }
}

//struct SpeechRecognitionView: View {
//    @State private var isRecording = false
//    @State private var recognizedText = ""
//    @State private var isTextFieldFocused = false
//    @State private var messageText = ""
//
//    var body: some View {
//        VStack {
//            HStack {
//                TextField("Type a message...", text: $messageText)
//                    .padding(10)
//                    .background(Color(.systemGray5))
//                    .clipShape(RoundedRectangle(cornerRadius: 20))
//                    .onTapGesture {
//                        isTextFieldFocused = true
//                    }
//
//                if isRecording {
//                    Button(action: stopRecording) {
//                        Image(systemName: "stop.circle")
//                            .font(.title)
//                            .foregroundColor(.red)
//                    }
//                } else {
//                    Button(action: startRecording) {
//                        Image(systemName: "mic.circle")
//                            .font(.title)
//                            .foregroundColor(.blue)
//                    }
//                    .disabled(isTextFieldFocused) // Disable when text field is focused
//                }
//            }
//            .padding()
//
//            Text("Recognized Text: \(recognizedText)")
//                .padding()
//        }
//        .padding(.bottom, isTextFieldFocused ? getKeyboardHeight() : 0)
//        .animation(.easeInOut(duration: 0.3))
//    }
//
//    func startRecording() {
//        SFSpeechRecognizer.requestAuthorization { status in
//            if status == .authorized {
//                try? startAudioEngine()
//                isRecording = true
//            }
//        }
//    }
//
//    func stopRecording() {
//        audioEngine.stop()
//        request.endAudio()
//        isRecording = false
//    }
//
//    private var audioEngine = AVAudioEngine()
//    private var request: SFSpeechAudioBufferRecognitionRequest!
//    private var recognitionTask: SFSpeechRecognitionTask!
//
//    func startAudioEngine() throws {
//        let audioSession = AVAudioSession.sharedInstance()
//        try audioSession.setCategory(.record, mode: .default, options: [])
//        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//
//        request = SFSpeechAudioBufferRecognitionRequest()
//        let inputNode = audioEngine.inputNode
//        let recordingFormat = inputNode.outputFormat(forBus: 0)
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
//            request.append(buffer)
//        }
//
//        audioEngine.prepare()
//        try audioEngine.start()
//
//        recognitionTask = SFSpeechRecognizer.shared().recognitionTask(with: request) { result, _ in
//            if let result = result {
//                recognizedText = result.bestTranscription.formattedString
//            }
//        }
//    }
//
//    func getKeyboardHeight() -> CGFloat {
//        return UIScreen.main.bounds.height > 800 ? 300 : 200
//    }
//}
//
//struct SpeechRecognitionView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpeechRecognitionView()
//    }
//}

struct MessageSwift: Identifiable {
    var id = UUID()
    var idString: String {
        id.uuidString
    }
    var content = ""
    var timestamp: Date = Date()
    var isSentByUser = false
    var character: Character
}


struct MessageScreen: View {
    
    @State var selectedMessage: Message? = nil
    
    @Binding var refreshID: UUID
    
    //    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    
    func dismissScreen() {
        dismiss()
    }
    
    @Environment(\.dismiss) var dismiss
    
    var character: Character
    
    // Fetch Messages from Core Data and sort by timestamp
    //    @FetchRequest(
    //        entity: Message.entity(),
    //        sortDescriptors: [NSSortDescriptor(keyPath: \Message.timestamp, ascending: true)]
    //    ) var messages: FetchedResults<Message>
    
    @State var messages: [Message]
    
    var messageIndexToScrollTo: Int?
    
    @State private var models: [String] = []
    
    @State private var messageText = ""
    @State private var responseText = ""
    @State private var isTextFieldFocused = false
    
    @State private var textFieldHeight: CGFloat = 70
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            NavigationBar(dismiss: dismissScreen, character: character, refreshID: $refreshID, isTextFieldFocused: $isTextFieldFocused)
            
            
            // Message List
            MessageList(isTextFieldFocused: $isTextFieldFocused, messages: $messages, selectedMessage: $selectedMessage, messageIndexToScrollTo: messageIndexToScrollTo, character: character)
            
            //            Text(speechRecognizer.transcript)
            // Text Input Field
//            ZStack {
//                Color.white.opacity(0.5) // Adjust opacity as needed
//                    .ignoresSafeArea()
//                    .frame(height: 45)
//                TextField("", text: $messageText, axis: .vertical)
//                    .background(Color.clear)
//                        .padding(10)
//                        .padding()
//                        .padding(.horizontal, 7.5)
//                        .background(Color(.clear))
//                        .foregroundColor(Color.clear)
//                        .overlay(RoundedRectangle(cornerRadius: 20)
//                            .stroke(Color.gray, lineWidth: 1)
//                            .padding(20)
//                        )
            Spacer()
            ZStack(alignment: .bottom) {
                Rectangle() // Add a rectangle as the first view
                    .foregroundColor(Color(uiColor: .systemBackground)) // Set the desired background color
                               .frame(height: textFieldHeight)
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.secondaryLabel), lineWidth: 1)
                    .frame(height: textFieldHeight-30)
                    .padding(.vertical, 17.5)
                    .padding(.horizontal, 25)
                    HStack(alignment: .bottom) {
                        TextField("Type a message...", text: $messageText, axis: .vertical)
                            .padding(10)
//                            .background(Color(.clear))
                            .onTapGesture {
                                // Assuming you want to set isTextFieldFocused here
                                
                            }
                            .background(GeometryReader { geo in
                                                Color.clear
                                                    .onAppear {
                                                        // Update the editor height when it appears
//                                                        textFieldHeight = geo.size.height + 30
                                                    }
                                                    .onChange(of: geo.size.height) { newHeight in
                                                        // Respond to changes in height
                                                            textFieldHeight = newHeight + 30
                                                        
                                                    }
                                            })
//                            .onChange(of: messageText) { _ in
//                                textFieldHeight = geo.size.height + 30
//                            }
                        if                         // make label transparent when blank
                            !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Button {
                                sendMessage()
                                //                    Task {
                                //                        await sendMessage()
                                //                    }
                            } label: {
                                ZStack {
                                    Circle()
                                        .frame(width: 30)
                                        .foregroundColor(.white)
                                        .padding(.bottom, 5)
                                        .padding(.trailing, 5)
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.system(size: 30))
                                        .padding(.bottom, 5)
                                        .padding(.trailing, 5)
                                }
                            }
                            //                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // disabled when blaul
                        }
                        
                        //
                        //            Button(action: sendAction) {
                        //                Image(systemName: "paperplane")
                        //                    .font(.headline)
                        //            }
                    }
                    .padding()
                    .padding(.horizontal, 7.5)
                    .gesture(
                        DragGesture().onChanged { value in
                            // If User is scrolling down on text field...
                            if value.translation.height > 0 {
                                //then, dismiss keyboard
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                
                            }
                        }
                    )
                
            }
//            }

            
            //            TextInputFieldView(text: $messageText, sendAction: sendMessage)
        }
//        .padding(.bottom, isTextFieldFocused ? getKeyboardHeight() : 0)
//        .animation(.easeInOut(duration: 0.3))
        .onReceive(Publishers.keyboardHeight) { height in
            self.isTextFieldFocused = height > 0
        }
//        .keyboardAdaptive() // Automatically adjust view position for keyboard
    }
    
    //    func startRecording() {
    //        SFSpeechRecognizer.requestAuthorization { status in
    //            if status == .authorized {
    //                try? startAudioEngine()
    //                isRecording = true
    //            }
    //        }
    //    }
    //
    //    func stopRecording() {
    //        audioEngine.stop()
    //        request.endAudio()
    //        isRecording = false
    //    }
    //
    //    var audioEngine = AVAudioEngine()
    //    @State var request: SFSpeechAudioBufferRecognitionRequest!
    //    @State var recognitionTask: SFSpeechRecognitionTask!
    //
    //    func startAudioEngine() throws {
    //        let audioSession = AVAudioSession.sharedInstance()
    //        try audioSession.setCategory(.record, mode: .default, options: [])
    //        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    //
    //        request = SFSpeechAudioBufferRecognitionRequest()
    //        let inputNode = audioEngine.inputNode
    //        let recordingFormat = inputNode.outputFormat(forBus: 0)
    //        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
    //            request.append(buffer)
    //        }
    //
    //        audioEngine.prepare()
    //        try audioEngine.start()
    //
    //        recognitionTask = SFSpeechRecognizer()?.recognitionTask(with: request) { result, _ in
    //            if let result = result {
    //                messageText = messageText + result.bestTranscription.formattedString
    //            }
    //        }
    //    }
    
    func sendMessage() {
        
        //create message object from user's sent text
        let message = Message(context: Constants.context)
        message.content = messageText
        message.isSentByUser = true
        message.set(character)
        
        //add to array to update view
        messages.append(message)
        
        //save sent message
        PersistenceController.shared.saveContext()
        
        //define prompt from message text
//        let prompt = character.promptFrom(messageText)
//        let prompt = messageText
        
        let prompt = character.promptWithContextFrom(messageText)
        
        //clear textfield
        messageText = ""
        
                APIHandler.shared.getResponse(input: prompt) { result in
                    switch result {
                    case .success(let output):
                        
//                        func removeEmptyAndPeriodLinesUntilText(from input: String) -> String {
//                            let lines = input.split(separator: "\n")
//                            var result = ""
//                            var foundText = false
//
//                            for line in lines {
//                                let trimmedLine = line.trimmingCharacters(in: .whitespaces)
//
//                                if !trimmedLine.isEmpty && trimmedLine != "." {
//                                    foundText = true
//                                    result += "\(line)\n"
//                                } else if foundText {
//                                    result += "\(line)\n"
//                                }
//                            }
//
//                            return result
//                        }

                        
//                        func removeEmptyFirstLines(from input: String) -> String {
//                            var lines = input.components(separatedBy: "\n")
//                            while let firstLine = lines.first, firstLine.isEmpty {
//                                lines.removeFirst()
//                            }
//                            return lines.joined(separator: "\n")
//                        }
//
//                        func removeLinesWithPeriods(from inputString: String) -> String {
//                            let lines = inputString.split(separator: "\n")
//                            let filteredLines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).contains(".") }
//                            let resultString = filteredLines.joined(separator: "\n")
//                            return resultString
//                        }
                        
                        //removes blank lines and "." lines and returns output
                        func removeUnwantedLines(from input: String) -> String {
                            
                            // Split the input string into an array of lines
                            let lines = input.split(separator: "\n")
                            // Create an empty string to store the result
                            var result = ""
                            // Create a flag to track whether text has been found
                            var foundText = false

                            for line in lines {
                                // Trim leading and trailing whitespaces from the line
                                let trimmedLine = line.trimmingCharacters(in: .whitespaces)

                                // Check if the trimmed line is not empty and not just a period
                                if !trimmedLine.isEmpty && trimmedLine != "." {
                                    // If text is found, set the flag to true and append the line to the result
                                    foundText = true
                                    result += "\(line)\n"
                                } else if foundText {
                                    // If text has been found previously, append the line to the result
                                    result += "\(line)\n"
                                }
                            }

                            // Remove the last line if it is blank
                            if result.last == "\n" {
                                result.removeLast()
                            }

                            // Return the properly formatted result
                            return result
                        }

                        //format string output to remove empty first line
//                        let formattedOutput =  output.trimmingCharacters(in: .newlines)
                        
                        let formattedOutput = removeUnwantedLines(from: output)
        
                        //create message object from string output
                        let message = Message(context: Constants.context)
                        if !formattedOutput.isEmpty {
                            message.content = formattedOutput
                        } else {
                            message.content = "..."
                        }
//                        message.content = removeEmptyFirstLines(from: output)
//                        message.content = removeLinesWithPeriods(from: output)
//                        message.content = output
                        message.set(character)
        
                        //save changes to core data
                        PersistenceController.shared.saveContext()
        
                        //append to array
                        self.messages.append(message)
        
                        self.models.append(output)
                        responseText = models.joined(separator: " ")
                    case .failure(let error):
                        print("RESPONSE failed")
                    }
                }
        
//        await APIHandler.shared.getResponseWithContext(input: prompt, character: character, messages: messages, completion: { result in
//            switch result {
//            case .success(let output):
//
//                //format string output to remove empty first line
//                let formattedOutput =  output.trimmingCharacters(in: .newlines)
//
//                //create message object from string output
//                let message = Message(context: Constants.context)
//                message.content = formattedOutput
//                message.set(character)
//
//                //save changes to core data
//                PersistenceController.shared.saveContext()
//
//                //append to array
//                self.messages.append(message)
//
//                self.models.append(output)
//                responseText = models.joined(separator: " ")
//            case .failure(let error):
//                print("RESPONSE failed")
//            }
//        })
    }
    
    //    func isMicrophoneInUse() -> Bool {
    //        let audioSession = AVAudioSession.sharedInstance()
    //        do {
    //            try audioSession.setCategory(.playAndRecord, options: .duckOthers)
    //            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    //            return false
    //        } catch {
    //            return true
    //        }
    //    }
    
    func getKeyboardHeight() -> CGFloat {
        return UIScreen.main.bounds.height > 800 ? 300 : 200
    }
    
}

struct MessageBubble: View {
    
    var text: String
    var timestamp: Date
    var isSentByUser: Bool
    
    @State var showTimestamp: Bool = false
    
    var body: some View {
        HStack() {
            if isSentByUser {
                Spacer() // Add a spacer to push the message bubble to the right edge
            }
            
            VStack(alignment: isSentByUser ? .trailing : .leading, spacing: 0) {
                HStack(spacing: 0) {
                    if !isSentByUser {
                        Triangle(direction: .southwest)
                            .fill(Color(.systemGray3))
                            .frame(width: 25, height: 10)
                            .offset(CGSize(width: 16, height: 15))
                        
                    }
                    Text(text)
                        .foregroundColor(isSentByUser ? .white : .black)
                        .padding(10)
                        .background(isSentByUser ? Color.blue : Color(.systemGray3))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    //prevents bubble from going too far to the opposite side
                    //                        .frame(maxWidth: .infinity)
                    //                        .padding(.leading, isSentByUser ? 100 : 0)
                    //                        .padding(.trailing, !isSentByUser ? 100 : 0)
                    if isSentByUser {
                        Triangle(direction: .southeast)
                            .fill(Color.blue)
                            .frame(width: 25, height: 10)
                            .offset(CGSize(width: -16, height: 15))
                    }
                    
                }
                if !isSentByUser {
                    Spacer() // Step 8: Add a spacer to push the message bubble to the left edge
                }
                if showTimestamp {
                    HStack {
                        if isSentByUser {
                            Spacer()
                            Text(timestamp.localizedTimeString)
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .padding(.trailing, 30)
                                .padding(.bottom, 1)
                        }
                        if !isSentByUser {
                            Text(timestamp.localizedTimeString)
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .padding(.leading, 30)
                                .padding(.bottom, 0)
                            Spacer()
                        }
                    }
                }
            }
            .onTapGesture {
                showTimestamp.toggle()
            }
        }
    }
}


extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

struct Triangle: Shape {
    var direction: TriangleDirection
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let startPoint = CGPoint(x: rect.width * direction.startPoint.x, y: rect.height * direction.startPoint.y)
        let midPoint = CGPoint(x: rect.width * direction.middlePoint.x, y: rect.height * direction.middlePoint.y)
        let endPoint = CGPoint(x: rect.width * direction.endPoint.x, y: rect.height * direction.endPoint.y)
        
        path.move(to: startPoint)
        path.addLine(to: midPoint)
        path.addLine(to: endPoint)
        path.closeSubpath()
        
        return path
    }
}

enum TriangleDirection {
    case north, northeast, east, southeast, south, southwest, west, northwest
    
    var startPoint: CGPoint {
        switch self {
        case .north: return CGPoint(x: 0.5, y: 0)
        case .northeast: return CGPoint(x: 1, y: 0)
        case .east: return CGPoint(x: 1, y: 0.5)
        case .southeast: return CGPoint(x: 1, y: 1)
        case .south: return CGPoint(x: 0.5, y: 1)
        case .southwest: return CGPoint(x: 0, y: 1)
        case .west: return CGPoint(x: 0, y: 0.5)
        case .northwest: return CGPoint(x: 0, y: 0)
        }
    }
    
    var middlePoint: CGPoint {
        return CGPoint(x: 0.5, y: -0.5)
    }
    
    var endPoint: CGPoint {
        return CGPoint(x: 0.5, y: 0.5)
    }
}
//In this modified code, the TriangleDirection enum now includes middlePoint, which is the point at the bottom-center of the triangle. The Triangle struct now uses this point to draw the isosceles triangle.
//
//You can use this updated Triangle struct with the direction parameter, and it will create an isosceles triangle as desired.
//

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

struct MessageScreen_Previews: PreviewProvider {
    static var previews: some View {
        
        let refreshID = Binding<UUID>(get: {
            // Return your initial value here
            return UUID()
        }, set: { newValue in
            // Handle the updated value here
        })
        
        MessageScreen(refreshID: refreshID, character: Character(context: PersistenceController.shared.container.viewContext), messages: [])
    }
}
