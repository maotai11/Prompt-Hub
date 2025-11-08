# Requirements Document

## Introduction

本功能為客戶資料庫系統新增一個「訊息模板系統」，允許使用者建立可重複使用的訊息模板，並透過標籤（變數）自動替換客戶資料，實現批次產生客製化訊息的功能。這將大幅提升使用者在發送通知、提醒或行銷訊息時的效率。

## Requirements

### Requirement 1: 訊息模板管理

**User Story:** 作為系統使用者，我想要能夠建立、編輯、刪除訊息模板，以便重複使用常見的訊息格式。

#### Acceptance Criteria

1. WHEN 使用者進入訊息模板頁面 THEN 系統 SHALL 顯示所有已建立的模板列表
2. WHEN 使用者點擊「新增模板」按鈕 THEN 系統 SHALL 開啟模板編輯表單
3. WHEN 使用者填寫模板名稱和內容後提交 THEN 系統 SHALL 儲存模板到 localStorage
4. WHEN 使用者點擊「編輯」按鈕 THEN 系統 SHALL 開啟該模板的編輯表單並載入現有內容
5. WHEN 使用者點擊「刪除」按鈕並確認 THEN 系統 SHALL 從 localStorage 移除該模板
6. WHEN 模板儲存成功 THEN 系統 SHALL 顯示成功訊息並更新模板列表

### Requirement 2: 動態模板變數標籤系統

**User Story:** 作為系統使用者，我想要在模板中使用變數標籤，並且標籤來源是動態從客戶資料庫欄位讀取，以便未來新增欄位時自動支援。

#### Acceptance Criteria

1. WHEN 使用者在模板內容中輸入 {{變數名稱}} THEN 系統 SHALL 識別為可替換的變數標籤
2. WHEN 系統初始化時 THEN 系統 SHALL 從客戶資料結構動態讀取所有可用欄位作為標籤選項
3. WHEN 模板編輯器顯示時 THEN 系統 SHALL 提供「插入標籤」按鈕
4. WHEN 使用者點擊「插入標籤」按鈕 THEN 系統 SHALL 顯示從客戶資料庫讀取的所有可用欄位列表
5. WHEN 使用者從列表選擇一個欄位 THEN 系統 SHALL 將該標籤（格式：{{欄位名稱}}）插入到游標位置
6. WHEN 客戶資料結構新增欄位 THEN 系統 SHALL 自動在標籤列表中包含新欄位（無需修改程式碼）
7. IF 客戶資料中某欄位為空 THEN 系統 SHALL 以空字串替換該標籤
8. WHEN 標籤選擇器顯示時 THEN 系統 SHALL 顯示欄位的中文名稱和對應的標籤格式

### Requirement 3: 批次訊息產生

**User Story:** 作為系統使用者，我想要選擇多筆客戶並套用模板，以便快速產生多組客製化訊息。

#### Acceptance Criteria

1. WHEN 使用者在客戶列表勾選多筆客戶 THEN 系統 SHALL 在批次操作列顯示「套用訊息模板」按鈕
2. WHEN 使用者點擊「套用訊息模板」按鈕 THEN 系統 SHALL 顯示可用模板列表
3. WHEN 使用者選擇一個模板 THEN 系統 SHALL 為每位選中的客戶產生一組客製化訊息
4. WHEN 訊息產生完成 THEN 系統 SHALL 顯示訊息預覽視窗，包含所有產生的訊息
5. WHEN 訊息預覽顯示時 THEN 每組訊息 SHALL 包含客戶識別資訊和完整訊息內容
6. WHEN 使用者點擊單一訊息的「複製」按鈕 THEN 系統 SHALL 複製該訊息到剪貼簿
7. WHEN 使用者點擊「全部複製」按鈕 THEN 系統 SHALL 複製所有訊息到剪貼簿（以分隔線區分）

### Requirement 4: 模板資料持久化

**User Story:** 作為系統使用者，我想要模板資料能夠儲存在本地並支援匯出/匯入，以便在不同裝置間同步或備份。

#### Acceptance Criteria

1. WHEN 使用者建立或修改模板 THEN 系統 SHALL 自動儲存到 localStorage（key: 'crm-message-templates'）
2. WHEN 頁面載入時 THEN 系統 SHALL 從 localStorage 讀取所有模板
3. WHEN 使用者點擊「匯出模板」按鈕 THEN 系統 SHALL 產生 JSON 檔案供下載
4. WHEN 使用者點擊「匯入模板」按鈕並選擇 JSON 檔案 THEN 系統 SHALL 讀取並合併模板資料
5. IF 匯入的模板 ID 與現有模板衝突 THEN 系統 SHALL 詢問使用者是否覆蓋或保留兩者
6. WHEN 匯入完成 THEN 系統 SHALL 顯示匯入結果（成功/失敗數量）

### Requirement 5: 模板編輯與標籤插入體驗

**User Story:** 作為系統使用者，我想要在編輯模板時能夠流暢地插入標籤，以便快速建立模板。

#### Acceptance Criteria

1. WHEN 使用者在模板內容輸入框中輸入文字 THEN 系統 SHALL 保持游標位置
2. WHEN 使用者點擊「插入標籤」按鈕 THEN 系統 SHALL 開啟標籤選擇器（modal 或 dropdown）
3. WHEN 標籤選擇器顯示時 THEN 系統 SHALL 列出所有可用欄位，格式為「中文名稱 ({{標籤}}）」
4. WHEN 使用者選擇一個標籤 THEN 系統 SHALL 將標籤插入到當前游標位置
5. WHEN 標籤插入後 THEN 系統 SHALL 自動關閉選擇器並將焦點返回輸入框
6. WHEN 使用者在模板編輯器中 THEN 系統 SHALL 提供「預覽」按鈕
7. WHEN 使用者點擊「預覽」按鈕 THEN 系統 SHALL 使用第一筆客戶資料作為範例顯示預覽
8. IF 模板中包含無效標籤（不在客戶資料欄位中） THEN 系統 SHALL 在預覽中保持原樣並以醒目方式標示

### Requirement 6: 使用者介面整合

**User Story:** 作為系統使用者，我想要訊息模板功能整合在現有系統中，以便無縫使用。

#### Acceptance Criteria

1. WHEN 系統載入時 THEN 系統 SHALL 在主選單新增「訊息模板」頁籤
2. WHEN 使用者在客戶列表選擇客戶時 THEN 批次操作列 SHALL 包含「套用訊息模板」選項
3. WHEN 使用者在單一客戶操作時 THEN 操作選單 SHALL 包含「套用訊息模板」選項
4. WHEN 訊息模板頁面顯示時 THEN 介面風格 SHALL 與現有系統一致（深色主題、金色強調）

### Requirement 7: 錯誤處理與驗證

**User Story:** 作為系統使用者，我想要系統能夠妥善處理錯誤情況，以便獲得清楚的回饋。

#### Acceptance Criteria

1. WHEN 使用者嘗試儲存空白模板名稱 THEN 系統 SHALL 顯示錯誤訊息並阻止儲存
2. WHEN 使用者嘗試儲存空白模板內容 THEN 系統 SHALL 顯示錯誤訊息並阻止儲存
3. WHEN localStorage 空間不足 THEN 系統 SHALL 顯示友善的錯誤訊息
4. WHEN JSON 匯入檔案格式錯誤 THEN 系統 SHALL 顯示具體的錯誤訊息
5. WHEN 使用者未選擇任何客戶就點擊「套用訊息模板」 THEN 系統 SHALL 提示需先選擇客戶
6. WHEN 系統操作失敗 THEN 系統 SHALL 記錄錯誤到 console 但不影響其他功能

## Data Model

### Template Object Structure
```javascript
{
  id: string,              // 唯一識別碼 (timestamp-based)
  name: string,            // 模板名稱
  content: string,         // 模板內容（含標籤）
  description: string,     // 模板描述（選填）
  createdAt: string,       // 建立時間
  updatedAt: string,       // 最後更新時間
  usageCount: number       // 使用次數（統計用）
}
```

### Available Tags (Dynamic)

標籤系統將動態從客戶資料結構讀取，預設包含但不限於：

**欄位映射表（Field Mapping）：**
```javascript
const fieldMapping = {
  'id': '客戶代號',
  'companyName': '公司名稱',
  'contact': '聯絡人',
  'phone': '電話',
  'taxId': '統一編號',
  'taxAddr': '稅籍編號',
  'regAddr': '設籍地址',
  'contactAddr': '聯絡地址',
  'leaseStart': '租約起日',
  'leaseEnd': '租約迄日'
};
```

**動態讀取邏輯：**
1. 系統啟動時讀取第一筆客戶資料的所有 keys
2. 排除系統欄位（如 notes）
3. 使用 fieldMapping 轉換為中文顯示名稱
4. 若 fieldMapping 中沒有對應，則直接使用欄位名稱

**標籤格式：** {{欄位名稱}}
**範例：** {{公司名稱}}、{{聯絡人}}、{{租約迄日}}

## Edge Cases

1. 模板中使用不存在的標籤 → 保持原樣不替換
2. 客戶資料欄位為空 → 替換為空字串
3. 同時編輯同一模板（多視窗） → 以最後儲存為準
4. 匯入大量模板導致 localStorage 超限 → 提示並允許選擇性匯入
5. 模板內容包含特殊字元 → 正確處理不破壞 JSON 格式

## Success Metrics

1. 使用者能在 30 秒內建立並套用一個新模板
2. 批次產生 10 筆客戶訊息的時間少於 5 秒
3. 模板資料能正確匯出/匯入不遺失
4. 所有標籤替換準確率 100%
5. 系統在處理 100+ 模板時仍保持流暢
