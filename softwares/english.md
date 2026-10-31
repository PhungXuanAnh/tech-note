> Download links point to the private [softwares repository](https://github.com/alexander1307xa/softwares). Sign in to GitHub with an account that has access; otherwise the links may return 404.

# English Learning Resources

## Download Files

Download the required files from the [GitHub Release](https://github.com/alexander1307xa/softwares/releases/tag/english-resources).

### Pronunciation Voice Packages

These voice packages add native pronunciation to dictionary applications like GoldenDict.

- [Longman 2005 Voice Package - American English.rar](https://github.com/alexander1307xa/softwares/releases/download/english-resources/Longman.2005.Voice.Package.-.American.English.rar) - American English pronunciation
- [Longman 2005 Voice Package - British.7z](https://github.com/alexander1307xa/softwares/releases/download/english-resources/Longman.2005.Voice.Package.-.British.7z) - British English pronunciation
- [Webster-Voice-Package-English.zip](https://github.com/alexander1307xa/softwares/releases/download/english-resources/Webster-Voice-Package-English.zip) - Webster dictionary pronunciation


### Dictionary Files for GoldenDict

Babylon dictionary files (`.bgl` format) for use with GoldenDict.

- [Prodict-English-Vietnamese-Technical.bgl](https://github.com/alexander1307xa/softwares/releases/download/english-resources/Prodict-English-Vietnamese-Technical.bgl) - English-Vietnamese technical dictionary
- [anhviet.bgl](https://github.com/alexander1307xa/softwares/releases/download/english-resources/anhviet.bgl) - Vietnamese-English dictionary

## Installation Instructions

### GoldenDict Installation

#### Ubuntu/Linux
```bash
sudo apt update
sudo apt install goldendict
```

#### Windows
Download GoldenDict from the official website or repository.

#### macOS
```bash
brew install --cask goldendict
```

### Installing Voice Packages

1. Download the desired voice package(s)
2. Extract the archive:
   - For `.rar` files: Use `unrar` or WinRAR
   - For `.7z` files: Use `7zip` or `p7zip`
   - For `.zip` files: Use built-in extraction tools

3. Copy the extracted voice files to GoldenDict's sound directory:
   - **Linux**: `~/.goldendict/content/`
   - **Windows**: `C:\Program Files\GoldenDict\content\`
   - **macOS**: `~/Library/Preferences/GoldenDict/content/`

4. Restart GoldenDict to activate pronunciation

### Installing Dictionary Files

1. Download the `.bgl` dictionary files
2. Copy them to GoldenDict's dictionary directory:
   - **Linux**: `~/.goldendict/` or create a custom folder
   - **Windows**: Create a folder like `C:\Dictionaries\`
   - **macOS**: Create a folder like `~/Documents/Dictionaries/`

3. In GoldenDict:
   - Go to **Edit → Dictionaries** (or **Preferences → Sources**)
   - Click **Add** under "Files" tab
   - Browse to the folder containing your `.bgl` files
   - Click **OK** and restart GoldenDict

## Usage Tips

- **Multiple Pronunciations**: Install both American and British voice packages to hear different accents
- **Custom Dictionary Folder**: Organize all your dictionaries in one folder for easier management
- **Dictionary Priority**: In GoldenDict settings, you can reorder dictionaries by priority
- **Scan Popup**: Enable scan popup in GoldenDict to get instant translations when hovering over words

## Notes

- Voice packages require GoldenDict or compatible dictionary software
- Babylon (`.bgl`) files are compatible with GoldenDict and other dictionary tools
- Some voice packages may be large; ensure you have sufficient storage space
