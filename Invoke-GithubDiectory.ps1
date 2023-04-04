function praseInfo($url) {
    $splitPath = $url -split "/" | Select-Object -Skip 3
    Write-Host $splitPath

    $info = @{}
    $info["author"] = "$($splitPath[0])"
    $info["repository"] = "$($splitPath[1])"
    $info["branch"] = ($splitPath[3]) ? "$($splitPath[3])" : "master"
    $info["directory"] = "$($splitPath[$splitPath.Length - 1])"
    $info["rootUrl"] = ($splitPath[3])?
    "https://github.com/$($splitPath[0])/$($splitPath[1])/tree/$($splitPath[3])" :
    "https://github.com/$($splitPath[0])/$($splitPath[1])"

    return $info
}

function getInfoUrl($author, $repository, $branch) {
    return  "https://api.github.com/repos/$($author)/$($repository)/git/trees/$($branch)?recursive=1"
}

function getDownloadUrl($author, $repository, $branch, $path) {
    return  "https://raw.githubusercontent.com/$($author)/$($repository)/$($branch)/$($path)"
}

function iterDirectory($repoInfo) {
    $infoUrl = getInfoUrl $repoInfo["author"] $repoInfo["repository"] $repoInfo["branch"]
    
    $res = $res = (Invoke-WebRequest $infoUrl).Content | ConvertFrom-Json
    if ($repoInfo["repository"] -eq $repoInfo["directory"]) {
        $res = $res.tree
    }
    else {
        $res = $res.tree | Where-Object { $_.path.Contains($repoInfo["directory"]) }
    }

    $res | ForEach-Object {
        $item = $_
        $paths = $item.path -split "/"
        $path = ""
        if ($repoInfo["repository"] -eq $repoInfo["directory"]) {
            $path = "$($repoInfo["repository"])/$($item.path)"
        }
        else {
            if ([array]::IndexOf($paths, $repoInfo["directory"]) -ne 0) {
                $i = [array]::IndexOf($paths, $repoInfo["directory"])
                $path = ($paths | Select-Object -Skip $i) -join "/"
            }
            else {
                $path = $paths -join "/"
            }
        }

        if ($item.type -eq "tree") {
            New-Item -Force -ItemType "directory" -Path $path 
        }
        elseif ($item.type -eq "blob") {
            $dwUrl = getDownloadUrl $repoInfo["author"] $repoInfo["repository"] $repoInfo["branch"] $item.path
            # Invoke-WebRequest -Uri $dwUrl -OutFile $path
            Start-ThreadJob -ScriptBlock {
                param($url, $path)
                Invoke-WebRequest -Uri $url -OutFile $path
            } -StreamingHost $Host -ArgumentList $dwUrl, $path | Out-Null
        }
    }
}

function Invoke-GithubDirectory($url) {
    if ($url -ne "" ) {
        if ($url -ne $null) {
            Set-Location "~\downloads"
            $info = praseInfo $url
            New-Item -Force -ItemType "directory" -Path "./$($info["directory"])"
            iterDirectory $info
        }
    }
}

# sample
# Invoke-GithubDirectory -url "https://github.com/wasd52030/pose-monitor"