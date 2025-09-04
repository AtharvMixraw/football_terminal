import os, strutils

const logoDir = "logos"

proc normalizeName(name: string): string =
  result = name.toLowerAscii()
  result = result.replace(" ", "_")

proc showLogo(club: string) =
  let filePath = logoDir / (normalizeName(club) & ".png")
  if fileExists(filePath):
    discard execShellCmd("chafa " & filePath)
  else:
    echo "Logo not found for: ", club

when isMainModule:
  echo "Available clubs:"
  for file in walkDir(logoDir):
    if file.path.endsWith(".png"):
      echo " - ", file.path.splitFile.name

  echo "\nEnter football club name:"
  let club = readLine(stdin)
  showLogo(club)
