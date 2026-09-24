# 研究所畢業資訊 FAQ

使用 MkDocs Material 製作的畢業資訊網站。正式網站由 GitHub Actions 在 `main` 分支更新時部署。

## 第一次使用這台電腦

需要 Git、Python 3.12 以上。在**不受 Google Drive 同步**的新資料夾中開啟終端機，執行：

```powershell
git clone https://github.com/chengcheng-cx/graduation-faq.git
cd graduation-faq
```

雙擊 `setup.cmd` 安裝網站套件並啟用本機的 Git 推送保護。每台電腦各執行一次。腳本會優先使用 Python 3.12，並把虛擬環境放在 `%USERPROFILE%\.graduation-faq\venv`；clone 不需要複製 `.venv` 或 `site` 資料夾。

網站套件版本列在 `requirements.in`；`requirements.txt` 鎖定完整相依套件。需要更新版本時，先修改 `requirements.in`，執行 `uv pip compile requirements.in --python-version 3.12 --output-file requirements.txt`，再執行 `check.cmd`。

## 平常編輯與發布

1. 開始編輯前，雙擊 `sync.cmd` 取得 GitHub 上的最新正式版。它會切換至 `main`；若有尚未提交的變更，會停止並提示先處理變更。
2. 編輯 `docs/` 內的網站內容；雙擊 `preview.cmd`，在 `http://127.0.0.1:8000/` 預覽。完成後關閉預覽視窗。
3. 雙擊 `check.cmd` 執行嚴格建置。雙擊 `update.cmd` 會再檢查一次、建立草稿分支、提交並推送到 GitHub；它不會直接更新正式網站。
4. 開啟 `update.cmd` 顯示的網址，建立 Pull Request。確認變更內容及 **Validate website** 檢查通過後，才在 GitHub 合併到 `main`；合併後才會自動部署。
5. 合併後，再雙擊 `sync.cmd` 更新本機 `main`。切換到另一台電腦時，也先在那台電腦執行 `sync.cmd`。

Git 的本機推送保護會阻止直接推送到 `main`。要在另一台電腦啟用相同保護，於該電腦執行一次 `setup.cmd`。

## 兩台電腦之間的檔案

此專案不使用 Google Drive 同步。每台電腦保留自己的 Git clone，透過 GitHub 上的 Pull Request 與 `sync.cmd` 交換已提交的變更。換電腦前，先完成提交、推送與合併；不要同時在兩台電腦編輯尚未同步的內容。

`git clone` 只會取得 Git 追蹤的檔案。專案外的檔案，以及被 `.gitignore` 排除的 `.obsidian/`、`.venv/`、`site/` 等本機資料，不會出現在另一台電腦。
