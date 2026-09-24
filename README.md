# 研究所畢業資訊 FAQ

使用 MkDocs Material 製作的畢業資訊網站。正式網站由 GitHub Actions 在 `main` 分支更新時部署。

## 第一次使用這台電腦

需要 Git、Python 3.12 以上。雙擊 `setup.cmd` 安裝網站套件。腳本會優先使用 Python 3.12，並把虛擬環境放在 `%USERPROFILE%\.graduation-faq\venv`，不使用 Google Drive 資料夾內由其他電腦同步過來的 `.venv`。

網站套件版本列在 `requirements.in`；`requirements.txt` 鎖定完整相依套件。需要更新版本時，先修改 `requirements.in`，執行 `uv pip compile requirements.in --python-version 3.12 --output-file requirements.txt`，再執行 `check.cmd`。

## 平常編輯與發布

1. 開始編輯前，等待 Google Drive 同步完成，並雙擊 `sync.cmd` 取得 GitHub 上的最新正式版。
2. 編輯 `docs/` 內的網站內容；雙擊 `preview.cmd`，在 `http://127.0.0.1:8000/` 預覽。完成後關閉預覽視窗。
3. 雙擊 `check.cmd` 執行嚴格建置。雙擊 `update.cmd` 會再檢查一次、建立草稿分支、提交並推送到 GitHub；它不會直接更新正式網站。
4. 開啟 `update.cmd` 顯示的網址，建立 Pull Request。確認變更內容及 **Validate website** 檢查通過後，才在 GitHub 合併到 `main`；合併後才會自動部署。
5. 合併後，再雙擊 `sync.cmd` 更新本機 `main`。另一台電腦開始工作前也要執行 `sync.cmd`。

Git 的本機推送保護會阻止直接推送到 `main`。要在另一台電腦啟用相同保護，於該電腦執行一次 `setup.cmd`。

## Google Drive 與 Git

Google Drive 用作檔案備份；GitHub 是網站版本與發布的依據。不要同時在兩台電腦編輯同一份專案，並在切換電腦前等待同步完成。這個資料夾目前含有由 Google Drive 同步的 `.git` 與舊 `.venv`；若 Git 再出現損壞或同步衝突，應在每台電腦各自建立不受 Google Drive 同步的 Git clone，透過 GitHub 交換變更。
