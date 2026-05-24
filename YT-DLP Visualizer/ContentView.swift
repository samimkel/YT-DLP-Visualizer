import SwiftUI
import Foundation

struct ContentView: View {
    // Arayüz değişkenleri (UI binding variables)
    @State private var videoURL: String = ""
    @State private var outputName: String = ""
    @State private var isAudioOnly: Bool = false
    @State private var downloadPlaylist: Bool = false // --- EKLENDİ ---
    
    // Kalite seçim durumları (Quality selection states)
    @State private var selectedVideoQuality: String = "Best"
    @State private var selectedAudioQuality: String = "320K"
    
    // Varsayılan indirme klasörü (Default to user's Downloads directory)
    @State private var downloadDirectory: URL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
    
    // Uygulama durumu ve log yazıları (Application state and logger text)
    @State private var logText: String = "Welcome! Ready to download.\n"
    @State private var isDownloading: Bool = false

    var body: some View {
        ZStack {
            // --- MODERN macOS STYLE GRADIENT BACKGROUND ---
            // Sistem penceresi arka plan rengi (Aydınlık/Karanlık mod uyumlu)
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()
            
            // Arka planda yumuşak, parıldayan mor ve mavi ışık küreleri (Mesh effect)
            GeometryReader { geo in
                ZStack {
                    // Sol üst köşedeki yumuşak mavi ışık
                    Circle()
                        .fill(Color(nsColor: .systemBlue).opacity(0.12))
                        .frame(width: geo.size.width * 0.7, height: geo.size.width * 0.7)
                        .blur(radius: 80)
                        .offset(x: -geo.size.width * 0.2, y: -geo.size.height * 0.15)
                    
                    // Sağ alt köşedeki yumuşak mor ışık
                    Circle()
                        .fill(Color(nsColor: .systemPurple).opacity(0.12))
                        .frame(width: geo.size.width * 0.7, height: geo.size.width * 0.7)
                        .blur(radius: 80)
                        .offset(x: geo.size.width * 0.5, y: geo.size.height * 0.45)
                }
            }
            .ignoresSafeArea()
            
            // --- MAIN INTERFACE CONTENT ---
            VStack(spacing: 15) {
                
                // Üst Başlık ve Logo Alanı (Premium Native macOS App Logo & Header)
                HStack(spacing: 15) {
                    ZStack {
                        // Modern macOS Squircle with Space Gradient
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color(nsColor: .systemBlue), Color(nsColor: .systemPurple)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 56, height: 56)
                            .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
                        
                        // Shiny metallic border effect
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(LinearGradient(
                                gradient: Gradient(colors: [.white.opacity(0.4), .clear, .black.opacity(0.2)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), lineWidth: 1)
                            .frame(width: 56, height: 56)
                        
                        // Glowing download vector design
                        ZStack {
                            Circle()
                               .stroke(LinearGradient(
                                    colors: [.white.opacity(0.5), .white.opacity(0.1)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ), lineWidth: 2.5)
                                .frame(width: 30, height: 30)
                            
                            Image(systemName: "arrow.down")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .offset(y: -1)
                                .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Samim's YT-DLP Visualizer")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Elegant & lightweight media manager")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 5)
                .padding(.top, 5)
                
                // Adım 1: Gereksinim Bilgilendirmesi (Step 1: Prerequisites Information)
                GroupBox(label: Text("Prerequisites").font(.headline)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("This application requires yt-dlp and ffmpeg to be installed on your system.")
                        Text("Please install them via Terminal using the following command:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("brew install yt-dlp ffmpeg")
                            .font(.system(.body, design: .monospaced))
                            .padding(8)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(5)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(5)
                }
                
                // Adım 2: İndirme Seçenekleri (Step 2: Download Options Form)
                GroupBox(label: Text("Step 2: Download Options").font(.headline)) {
                    VStack(alignment: .leading, spacing: 15) {
                        
                        // URL Giriş Alanı (URL Input field)
                        HStack {
                            Text("Video URL:")
                                .frame(width: 110, alignment: .trailing)
                            TextField("Paste YouTube or other supported video link here", text: $videoURL)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Dosya Adı Giriş Alanı (Custom filename input field)
                        HStack {
                            Text("Output Name:")
                                .frame(width: 110, alignment: .trailing)
                            TextField("e.g. MyVideo (leave blank for default title)", text: $outputName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Klasör Seçimi (Save Destination Selection)
                        HStack {
                            Text("Save To:")
                                .frame(width: 110, alignment: .trailing)
                            
                            Text(downloadDirectory.path)
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(5)
                            
                            Button("Choose...") {
                                chooseDirectory()
                            }
                        }
                        
                        // Format Değiştirici (Format Selector)
                        HStack {
                            Text("Format:")
                                .frame(width: 110, alignment: .trailing)
                            Toggle(isOn: $isAudioOnly) {
                                Text(isAudioOnly ? "Audio Only (MP3)" : "Video + Audio (MP4)")
                            }
                            .toggleStyle(SwitchToggleStyle())
                        }
                        
                        // --- PLAYLIST TOGGLE EKLENDİ ---
                        HStack {
                            Text("Playlist:")
                                .frame(width: 110, alignment: .trailing)
                            Toggle(isOn: $downloadPlaylist) {
                                Text(downloadPlaylist ? "Download Entire Playlist" : "Single Video Only")
                            }
                            .toggleStyle(SwitchToggleStyle())
                        }
                        // -------------------------------
                        
                        // Dinamik Kalite Seçici (Dynamic Quality Picker)
                        HStack {
                            Text("Quality:")
                                .frame(width: 110, alignment: .trailing)
                            
                            if isAudioOnly {
                                // Ses Kalitesi Seçici (Audio Quality Picker)
                                Picker("", selection: $selectedAudioQuality) {
                                    Text("Best (320 kbps)").tag("320K")
                                    Text("High (256 kbps)").tag("256K")
                                    Text("Medium (192 kbps)").tag("192K")
                                    Text("Standard (128 kbps)").tag("128K")
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                // Video Kalitesi Seçici (Video Quality Picker)
                                Picker("", selection: $selectedVideoQuality) {
                                    Text("Best Quality").tag("Best")
                                    Text("1080p Full HD").tag("1080p")
                                    Text("720p HD").tag("720p")
                                    Text("480p SD").tag("480p")
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        // İndir Butonu (Action Trigger Button)
                        HStack {
                            Spacer()
                            Button(action: {
                                startDownload()
                            }) {
                                Text("START DOWNLOAD")
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(isDownloading ? Color.gray : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(isDownloading || videoURL.isEmpty)
                            Spacer()
                        }
                    }
                    .padding(10)
                }
                
                // Konsol Günlüğü (Console Logs Output Screen)
                GroupBox(label: Text("Console Output").font(.headline)) {
                    ScrollViewReader { scrollView in
                        ScrollView {
                            Text(logText)
                                .font(.system(.caption, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .id("logBottom")
                        }
                        .onChange(of: logText) { oldValue, newValue in
                            withAnimation {
                                scrollView.scrollTo("logBottom", anchor: .bottom)
                            }
                        }
                    }
                    .frame(height: 120)
                    .background(Color(NSColor.textBackgroundColor).opacity(0.85)) // Hafif transparanlık katıldı
                    .cornerRadius(5)
                }
            }
            .padding()
        }
        .frame(minWidth: 550, minHeight: 700)
    }
    
    // Konsola güvenli şekilde log yazdırma (Helper to log console output safely)
    private func appendLog(_ message: String) {
        DispatchQueue.main.async {
            self.logText += message + "\n"
        }
    }
    
    // Klasör seçim penceresini açar (Opens native macOS Open Panel for directory selection)
    private func chooseDirectory() {
        let panel = NSOpenPanel()
        panel.title = "Select Download Directory"
        panel.showsHiddenFiles = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                self.downloadDirectory = url
            }
        }
    }
    
    // --- İNDİRME VE KOMUT ÇALIŞTIRMA MANTIĞI (DOWNLOAD AND COMMAND EXECUTION LOGIC) ---
    private func startDownload() {
        guard !videoURL.isEmpty else { return }
        
        isDownloading = true
        appendLog("\n--- Starting Download ---")
        
        // Hedef klasör yolunu al (Get target download directory path)
        let targetDirectory = downloadDirectory.path
        
        // Terminal parametrelerini hazırla (Prepare terminal arguments for yt-dlp)
        var arguments = [String]()
        
        if isAudioOnly {
            appendLog("Mode: Audio Extraction (MP3)")
            appendLog("Quality: \(selectedAudioQuality) bps")
            arguments.append(contentsOf: ["-x", "--audio-format", "mp3", "--audio-quality",selectedAudioQuality])
        } else {
            appendLog("Mode: Video (MP4)")
            appendLog("Selected Resolution Limit: \(selectedVideoQuality)")
            
            // Kalite kısıtlamalarını dinamik ayarlama (Flexibly requests best formats for ffmpeg compatibility)
            let formatArg: String
            switch selectedVideoQuality {
            case "1080p":
                formatArg = "bestvideo[height<=1080]+bestaudio/best[height<=1080]"
            case "720p":
                formatArg = "bestvideo[height<=720]+bestaudio/best[height<=720]"
            case "480p":
                formatArg = "bestvideo[height<=480]+bestaudio/best[height<=480]"
            default: // "Best"
                formatArg = "bestvideo+bestaudio/best"
            }
            arguments.append(contentsOf: ["-f", formatArg, "--merge-output-format", "mp4"])
        }
        
        let safeName = outputName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !safeName.isEmpty {
            let ext = isAudioOnly ? ".mp3" : ".mp4"
            let finalName = safeName.hasSuffix(ext) ? safeName : safeName + ext
            arguments.append(contentsOf: ["-o", "\(targetDirectory)/\(finalName)"])
            appendLog("Target File: \(targetDirectory)/\(finalName)")
        } else {
            arguments.append(contentsOf: ["-o", "\(targetDirectory)/%(title)s.%(ext)s"])
            appendLog("Target Directory: \(targetDirectory) (Using default video/audio title)")
        }
        
        // --- PLAYLIST KONTROLÜ EKLENDİ ---
        if downloadPlaylist {
            arguments.append("--yes-playlist")
            appendLog("⚠️ Playlist Mode: Downloading entire playlist if applicable.")
        } else {
            arguments.append("--no-playlist")
            appendLog("🛡️ Shield Active: Single video mode.")
        }
        // ---------------------------------
        
        arguments.append(videoURL)
        
        // Komutu arka planda asenkron çalıştır (Run download command as an asynchronous background thread)
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            
            // Bilgisayardaki yt-dlp konumunu tara (Scans local paths for yt-dlp)
            let fileManager = FileManager.default
            var ytdlpPath = "/opt/homebrew/bin/yt-dlp" // Apple Silicon Mac varsayılanı
            
            if !fileManager.fileExists(atPath: ytdlpPath) {
                if fileManager.fileExists(atPath: "/usr/local/bin/yt-dlp") {
                    ytdlpPath = "/usr/local/bin/yt-dlp" // Intel Mac varsayılanı
                } else if fileManager.fileExists(atPath: "/usr/bin/yt-dlp") {
                    ytdlpPath = "/usr/bin/yt-dlp"
                }
            }
            
            self.appendLog("🔍 Detected yt-dlp path: \(ytdlpPath)")
            
            task.executableURL = URL(fileURLWithPath: ytdlpPath)
            
            // Adjust environment PATH variables so subprocess commands find ffmpeg and yt-dlp correctly
            var environment = ProcessInfo.processInfo.environment
            let customPath = "/opt/homebrew/bin:/usr/local/bin"
            let existingPath = environment["PATH"] ?? ""
            environment["PATH"] = "\(customPath):\(existingPath)"
            task.environment = environment
            
            // Arguments are passed directly to yt-dlp
            task.arguments = arguments
            
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe
            
            let fileHandle = pipe.fileHandleForReading
            fileHandle.readabilityHandler = { handle in
                if let data = String(data: handle.availableData, encoding: .utf8), !data.isEmpty {
                    self.appendLog(data.trimmingCharacters(in: .newlines))
                }
            }
            
            do {
                try task.run()
                task.waitUntilExit()
                
                DispatchQueue.main.async {
                    if task.terminationStatus == 0 {
                        self.appendLog("✅ Download finished successfully!")
                    } else {
                        self.appendLog("❌ Download failed (Error Code \(task.terminationStatus)).")
                        self.appendLog("Note: Make sure to turn off 'App Sandbox' in your Xcode project settings.")
                    }
                    self.isDownloading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.appendLog("❌ yt-dlp not found or failed to execute at: \(ytdlpPath)")
                    self.appendLog("Error details: \(error.localizedDescription)")
                    self.isDownloading = false
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
