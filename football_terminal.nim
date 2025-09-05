import os, random, terminal, tables

const 
    logoDir = "/usr/local/share/football-clubs/logos"
    userLogoDir = getHomeDir() / ".local/share/football-clubs-logos"

type
    ClubInfo = object 
        name: string
        colors: seq[string]
        nickname: string
        league: string

# Football club data
const clubs = {
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
    if dirExists(logoDir):
        return logoDir
    elif dirExists(userLogoDir):
        return userLogoDir
    else:
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
        echo " No club logos found. Run 'football-clubs install' first!"
        return

    randomize()
    let clubKey = availableClubs[rand(availableClubs.len - 1)]
    let club = clubs[clubKey]
    let logoPath = getLogoPath() / (clubKey & ".png")

    #show the logo with chafa
    discard execShellCmd("chafa --size=30x15 --colors=256 " & logoPath)
    # Show club info with colors
    styledEcho fgYellow, styleBright, "⚽ ", club.name
    if club.nickname != "":
      styledEcho fgCyan, "   \"", club.nickname, "\""
    styledEcho fgGreen, "   ", club.league
    echo ""

when isMainModule:
    let args = commandLineParams()

    if args.len == 0:
        showRandomClub()
