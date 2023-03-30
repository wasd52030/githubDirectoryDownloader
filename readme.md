# githubDirectoryDownloader

一個用來下載**github**資料夾的小工具，以**powershell**撰寫

- 版本要求: **powershell7**$\uparrow$
- 目前只支援下載資料夾，單檔下載可以直接從github網頁上面獲得

## 安裝

- 安裝powershell 7(已安裝可以跳過)

- 打開powershell 7(pwsh)

    - clone本專案，並放到你喜歡的地方

        ```
        git clone https://github.com/wasd52030/githubDirectoryDownloader
        ```

    - 開啟user profile(編輯器自選)

        ```
        notepad $PROFILE
        ```

    - 載入指令碼

      ```
      Import-Module -Name "yourpath\githubDirectoryDownloader\Invoke-GithubDiectory.ps1"
      ```

 ## 使用
指令格式如下，**githuburl**為你想下載的github repository網址(資料夾網址亦可)
 ```
Invoke-GithubDirectory -url githuburl
 ```

例如: ``Invoke-GithubDirectory -url https://github.com/wasd52030/githubDirectoryDownloader``
