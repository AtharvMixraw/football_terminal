import os, strutils, random, terminal, tables

const 
  logoDir = "/usr/local/share/football-clubs/logos"
  # Alternative user directory if system-wide install fails
  userLogoDir = getHomeDir() / ".local/share/football-clubs/logos"

type
  ClubInfo = object
    name: string
    colors: seq[string]
    nickname: string
    league: string

# Football club data
let clubs = {
  "barcelona": ClubInfo(
    name: "FC Barcelona", 
    colors: @["blue", "red"], 
    nickname: "Barça", 
    league: "La Liga"
  ),
  "real_madrid": ClubInfo(
    name: "Real Madrid", 
    colors: @["white"], 
    nickname: "Los Blancos", 
    league: "La Liga"
  ),
  "manchester_united": ClubInfo(
    name: "Manchester United", 
    colors: @["red"], 
    nickname: "Red Devils", 
    league: "Premier League"
  ),
  "liverpool": ClubInfo(
    name: "Liverpool FC", 
    colors: @["red"], 
    nickname: "The Reds", 
    league: "Premier League"
  ),
  "bayern_munich": ClubInfo(
    name: "Bayern Munich", 
    colors: @["red", "white"], 
    nickname: "Die Bayern", 
    league: "Bundesliga"
  ),
  "juventus": ClubInfo(
    name: "Juventus", 
    colors: @["black", "white"], 
    nickname: "Juve", 
    league: "Serie A"
  )
}.toTable()

proc getLogoPath(): string =
  # Debug: print what we're checking
  when defined(debug):
    echo "Checking system path: ", logoDir
    echo "Checking user path: ", userLogoDir
  
  if dirExists(logoDir):
    when defined(debug):
      echo "Found system path"
    return logoDir
  elif dirExists(userLogoDir):
    when defined(debug):
      echo "Found user path"
    return userLogoDir
  else:
    when defined(debug):
      echo "No logo directory found"
      echo "System path exists: ", dirExists(logoDir)
      echo "User path exists: ", dirExists(userLogoDir)
      echo "User home: ", getHomeDir()
    return ""

proc getAvailableClubs(): seq[string] =
  let logoPath = getLogoPath()
  if logoPath == "":
    return @[]
  
  for club in clubs.keys:
    let filePath = logoPath / (club & ".png")
    if fileExists(filePath):
      result.add(club)

proc showRandomClub() =
  let availableClubs = getAvailableClubs()
  if availableClubs.len == 0:
    echo "⚽ No club logos found. Run 'football-clubs install' first!"
    return
  
  randomize()
  let clubKey = availableClubs[rand(availableClubs.len - 1)]
  let club = clubs[clubKey]
  let logoPath = getLogoPath() / (clubKey & ".png")
  
  # Show the logo with chafa
  discard execShellCmd("chafa --size=30x15 --colors=256 " & logoPath)
  
  # Show club info with colors
  styledEcho fgYellow, styleBright, "⚽ ", club.name
  if club.nickname != "":
    styledEcho fgCyan, "   \"", club.nickname, "\""
  styledEcho fgGreen, "   ", club.league
  echo ""

proc showSpecificClub(clubName: string) =
  let logoPath = getLogoPath()
  if logoPath == "":
    echo "⚠️ Logo directory not found!"
    return
  
  let normalizedName = clubName.toLowerAscii().replace(" ", "_").replace("-", "_")
  
  if not clubs.hasKey(normalizedName):
    echo "⚠️ Club not found: ", clubName
    echo "Available clubs:"
    for club in clubs.keys:
      echo "  - ", clubs[club].name
    return
  
  let filePath = logoPath / (normalizedName & ".png")
  if not fileExists(filePath):
    echo "⚠️ Logo file not found: ", filePath
    return
  
  let club = clubs[normalizedName]
  discard execShellCmd("chafa --size=30x15 --colors=256 " & filePath)
  
  styledEcho fgYellow, styleBright, "⚽ ", club.name
  if club.nickname != "":
    styledEcho fgCyan, "   \"", club.nickname, "\""
  styledEcho fgGreen, "   ", club.league
  echo ""

proc listClubs() =
  echo "⚽ Available Football Clubs:"
  echo "=" .repeat(30)
  for club in clubs.values:
    styledEcho fgYellow, "• ", club.name, resetStyle, " (", club.nickname, ")"

proc installLogos() =
  echo "📥 Installing football club logos..."
  
  # Try system directory first, fallback to user directory
  var targetDir = logoDir
  try:
    createDir(logoDir)
  except:
    targetDir = userLogoDir
    createDir(userLogoDir)
  
  echo "Installing to: ", targetDir
  
  # This would download or copy logos from a source
  echo "⚠️ Logo installation not implemented yet."
  echo "Please manually place club logos in: ", targetDir
  echo "Required files:"
  for club in clubs.keys:
    echo "  - ", club, ".png"

proc showHelp() =
  echo """
football-clubs - Show football club logos in terminal

Usage:
  football-clubs                    Show random club
  football-clubs random            Show random club  
  football-clubs [club-name]       Show specific club
  football-clubs list              List available clubs
  football-clubs install          Install logo files
  football-clubs help              Show this help

Examples:
  football-clubs barcelona
  football-clubs "real madrid"
  football-clubs manchester_united

Add to your shell profile to show on terminal startup:
  
  For bash (~/.bashrc):
    football-clubs
  
  For zsh (~/.zshrc):
    football-clubs
  
  For fish (~/.config/fish/config.fish):
    football-clubs
"""

when isMainModule:
  let args = commandLineParams()
  
  if args.len == 0:
    showRandomClub()
  else:
    case args[0].toLowerAscii():
    of "random", "rand", "r":
      showRandomClub()
    of "list", "ls", "l":
      listClubs()
    of "install", "setup":
      installLogos()
    of "help", "--help", "-h":
      showHelp()
    else:
      let clubName = args.join(" ")
      showSpecificClub(clubName)